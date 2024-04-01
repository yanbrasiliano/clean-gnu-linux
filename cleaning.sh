#!/usr/bin/env bash

set -e
trap 'echo "An error occurred. Exiting..." >&2' ERR

if [ "$SUDO_USER" ]; then
  REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
  REAL_HOME=$HOME
fi

LOG_FILE="$REAL_HOME/update.log"
THUMBNAILS_DIR="$REAL_HOME/.thumbnails/normal"
SLEEP_TIME=1

[[ $EUID -eq 0 ]] || {
  echo "This script must be run as root." >&2
  exit 1
}

log_message() {
  echo "----------[ $(whoami) $(date) ]---------- $1" >>"${LOG_FILE}"
}

clean_directory() {
  local dir=$1
  [[ -n "$dir" && -d "$dir" ]] || {
    echo "Directory ${dir} not found, skipping."
    return
  }
  echo "Cleaning $dir..."
  find "${dir}" -mindepth 1 -exec rm -rf {} + 2>/dev/null
  du -sh "${dir}"
  sleep "${SLEEP_TIME}"
}

apt_operations() {
  log_message
  echo 'Updating package lists...'
  apt update -y
  echo 'Upgrading packages...'
  apt upgrade -y
  apt full-upgrade -y
  echo 'Removing unused packages...'
  apt autoremove --purge -y
  echo 'Cleaning local repository...'
  apt autoclean
}

remove_old_kernels() {
  echo 'Removing old kernels...'
  apt autoremove --purge
}

remove_old_configs() {
  echo 'Removing old configuration files...'
  dpkg -l | grep '^rc' | awk '{print $2}' | xargs -r dpkg --purge
}

update_system() {
  apt_operations
  remove_old_kernels
  remove_old_configs

  clean_directory "${THUMBNAILS_DIR}"
  clean_directory "$REAL_HOME/.cache/thumbnails/normal"
  clean_directory "$REAL_HOME/.local/share/Trash"
  clean_directory "$REAL_HOME/.cache"
  clean_directory "$REAL_HOME/Downloads"
  clean_directory "/var/cache/apt/archives"
  clean_directory "/var/tmp"
  clean_directory "/var/log"
  clean_directory "/var/backups"

  [[ "$HOME" != "/root" ]] || clean_directory "/root"

  echo 'Fixing broken packages with dpkg...'
  dpkg --configure -a
  echo 'Cleaning old logs...'
  journalctl --vacuum-size=50M
  echo 'Removing old snaps...'
  snap list --all | awk '/disabled/{print $1, $3}' |
    while read -r snapname revision; do
      snap remove "$snapname" --revision="$revision"
    done

  df -Th | sort
}

update_system
