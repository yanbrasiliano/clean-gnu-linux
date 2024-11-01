#!/usr/bin/env bash

set -e
trap 'echo "An error occurred. Exiting..." >&2; exit 1' ERR

[[ $EUID -eq 0 ]] || {
  echo "This script must be run as root." >&2
  exit 1
}
if [ "$SUDO_USER" ]; then
  REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
  REAL_HOME=$HOME
fi

LOG_FILE="$REAL_HOME/update.log"
ERROR_LOG="$REAL_HOME/update_errors.log"
THUMBNAILS_DIR="$REAL_HOME/.thumbnails/normal"
CACHE_DIR="$REAL_HOME/.cache"
SLEEP_TIME=1
SKIP_DOCKER=0

while [[ "$#" -gt 0 ]]; do
  case $1 in
  --skip-docker) SKIP_DOCKER=1 ;;
  *)
    echo "Unknown parameter: $1" >&2
    exit 1
    ;;
  esac
  shift
done

log_message() {
  echo "----------[ $(whoami) $(date) ]---------- $1" >>"${LOG_FILE}"
}

check_network() {
  if ! ping -c 1 google.com &>/dev/null; then
    echo "No network connection. Exiting..." >&2
    exit 1
  fi
}

clean_directory() {
  local dir=$1
  [[ -n "$dir" && -d "$dir" ]] || {
    echo "Directory ${dir} not found, skipping." >>"${ERROR_LOG}"
    return
  }
  echo "Cleaning $dir..."
  find "${dir}" -mindepth 1 -exec rm -rf {} + 2>/dev/null
  du -sh "${dir}" >>"${LOG_FILE}"
  sleep "${SLEEP_TIME}"
}

apt_operations() {
  log_message "Starting APT operations"
  check_network
  echo 'Updating package lists...'
  apt-get update -y
  apt-get upgrade -y && apt-get full-upgrade -y
  echo 'Removing unused packages...'
  apt-get autoremove --purge -y
  apt-get autoclean
}

clean_docker() {
  if [[ "$SKIP_DOCKER" -eq 0 ]]; then
    if command -v docker &>/dev/null; then
      echo 'Cleaning Docker...'
      docker system prune -a -f --volumes
    else
      echo "Docker not found, skipping Docker cleanup." >>"${ERROR_LOG}"
    fi
  else
    echo "Skipping Docker cleanup as per user request."
  fi
}

clean_journal() {
  journalctl --vacuum-size=50M
}

clean_systemd_resolved() {
  rm -rf /var/cache/systemd/resolved
  systemctl restart systemd-resolved
}

update_system() {
  apt_operations
  clean_directory "${THUMBNAILS_DIR}"
  clean_directory "$REAL_HOME/.cache/thumbnails/normal"
  clean_directory "$REAL_HOME/.local/share/Trash"

  [[ $(pgrep -x "chrome") ]] || clean_directory "${CACHE_DIR}"

  for dir in "$REAL_HOME/Downloads" "$REAL_HOME/Pictures/Screenshots" "/var/cache/apt/archives" "/var/tmp" "/var/log" "/var/backups" "/root/.cache"; do
    clean_directory "$dir"
  done

  [[ "$HOME" != "/root" ]] || clean_directory "/root"

  dpkg --configure -a
  clean_journal
  clean_docker
  clean_systemd_resolved

  echo "Disk usage after cleanup:"
  df -h | sort
}

exec > >(tee -a "${LOG_FILE}") 2> >(tee -a "${ERROR_LOG}" >&2)
update_system
