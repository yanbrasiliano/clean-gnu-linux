#!/usr/bin/env bash

set -e
trap 'echo "An error occurred. Exiting..." >&2; exit 1' ERR

if [ "$SUDO_USER" ]; then
  REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
  REAL_HOME=$HOME
fi

LOG_FILE="$REAL_HOME/update.log"
THUMBNAILS_DIR="$REAL_HOME/.thumbnails/normal"
CACHE_DIR="$REAL_HOME/.cache"
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
  log_message "Starting APT operations"
  echo 'Updating package lists...'
  apt update -y
  echo 'Upgrading packages...'
  apt upgrade -y
  apt full-upgrade -y
  echo 'Removing unused packages...'
  apt autoremove --purge -y
  echo 'Cleaning local repository of packages...'
  apt autoclean
}

remove_old_kernels() {
  echo 'Removing old kernels...'
  apt autoremove --purge -y
}

remove_old_configs() {
  echo 'Removing old configuration files...'
  dpkg -l | grep '^rc' | awk '{print $2}' | xargs -r dpkg --purge
}

clean_docker() {
  echo 'Cleaning Docker...'
  docker system prune -a -f --volumes
}

clean_journal() {
  echo 'Cleaning journal logs...'
  journalctl --vacuum-size=50M
}

clean_systemd_resolved() {
  echo 'Cleaning systemd-resolved cache...'
  rm -rf /var/cache/systemd/resolved
  systemctl restart systemd-resolved
}

update_system() {
  apt_operations
  remove_old_kernels
  remove_old_configs

  clean_directory "${THUMBNAILS_DIR}"
  clean_directory "$REAL_HOME/.cache/thumbnails/normal"
  clean_directory "$REAL_HOME/.local/share/Trash"

  if ! pgrep -x "chrome" >/dev/null; then
    clean_directory "${CACHE_DIR}"
  else
    echo "Google Chrome is running; skipping cache cleanup."
  fi

  clean_directory "$REAL_HOME/Downloads"
  clean_directory "/var/cache/apt/archives"
  clean_directory "/var/tmp"
  clean_directory "/var/log"
  clean_directory "/var/backups"
  clean_directory "/root/.cache"

  [[ "$HOME" != "/root" ]] || clean_directory "/root"

  echo 'Fixing broken packages with dpkg...'
  dpkg --configure -a
  echo 'Cleaning old logs...'
  clean_journal
  clean_docker
  clean_systemd_resolved
  df -Th | sort
}

update_system
