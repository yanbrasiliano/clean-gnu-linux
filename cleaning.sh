#!/usr/bin/env bash

set -e
trap 'echo "An error occurred. Exiting..." >&2; exit 1' ERR

[[ $EUID -eq 0 ]] || {
    echo "This script must be run as root." >&2
    exit 1
}

LOG_FILE="/var/log/system_cleaner.log"
ERROR_LOG="/var/log/system_cleaner_errors.log"
SLEEP_TIME=1
DRY_RUN=0
SKIP_DOCKER=0

log_message() {
    echo "----------[ $(whoami) $(date) ]---------- $1" >>"${LOG_FILE}"
}

clean_directory() {
    local dir=$1
    if [[ -n "$dir" && -d "$dir" ]]; then
        if [[ "$DRY_RUN" -eq 1 ]]; then
            echo "Dry-run: Would clean $dir"
        else
            echo "Cleaning $dir..."
            find "$dir" -mindepth 1 -exec rm -rf {} + 2>/dev/null
            du -sh "$dir" >>"${LOG_FILE}"
        fi
    else
        echo "Directory $dir not found, skipping." >>"${ERROR_LOG}"
    fi
    sleep "${SLEEP_TIME}"
}

check_command() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "Error: $1 is not installed. Please install it first." >&2
        exit 1
    }
}

show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    echo -n "Loading "
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    echo "Done!"
}

print_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  --dry-run        Simulate actions without making changes"
    echo "  --skip-docker    Skip Docker cleanup"
    echo "  --help           Show this help message"
    exit 0
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
    --dry-run) DRY_RUN=1 ;;
    --skip-docker) SKIP_DOCKER=1 ;;
    --help) print_help ;;
    *)
        echo "Unknown parameter: $1" >&2
        exit 1
        ;;
    esac
    shift
done

perform_cleanup() {
    local dirs=(
        "/var/cache/apt/archives"
        "/var/tmp"
        "/var/log"
        "/var/backups"
        "/root/.cache"
        "$HOME/.cache"
        "$HOME/.local/share/Trash"
    )

    for dir in "${dirs[@]}"; do
        clean_directory "$dir" &
    done
    wait
}

update_system() {
    log_message "Starting APT operations"
    check_command apt-get
    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "Dry-run: Would update and upgrade system packages"
    else
        echo 'Updating package lists...'
        apt-get update -y &
        show_spinner $!
        apt-get upgrade -y && apt-get full-upgrade -y &
        show_spinner $!
        echo 'Removing unused packages...'
        apt-get autoremove --purge -y &
        show_spinner $!
        apt-get autoclean &
        show_spinner $!
    fi
}

clean_docker() {
    if [[ "$SKIP_DOCKER" -eq 1 ]]; then
        echo "Skipping Docker cleanup as per user request."
    elif command -v docker &>/dev/null; then
        if [[ "$DRY_RUN" -eq 1 ]]; then
            echo "Dry-run: Would clean Docker system"
        else
            echo 'Cleaning Docker...'
            docker system prune -a -f --volumes &
            show_spinner $!
        fi
    else
        echo "Docker not found, skipping Docker cleanup." >>"${ERROR_LOG}"
    fi
}

log_message "Starting cleanup process"
update_system
perform_cleanup
clean_docker

if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "Dry-run completed. No changes were made."
else
    echo "System cleanup completed successfully."
fi
