#!/usr/bin/env bash

set -e

# Define variables
LOG_FILE="$HOME/update.log"
THUMBNAILS_DIR="$HOME/.thumbnails/normal"
SLEEP_TIME=1

# Check for root permissions
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

log_message() {
  echo "----------[ $(whoami) $(date) ]----------" >> "${LOG_FILE}"
}

clean_directory() {
  local dir=$1
  if [ -d "${dir}" ]; then
    echo "Cleaning ${dir}..."
    rm -rf "${dir:?}"/*
    du -sh "${dir}"
    sleep "${SLEEP_TIME}"
  else
    echo "Directory ${dir} not found, skipping."
  fi
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
  clean_directory "/var/cache/apt/archives"
  clean_directory "$HOME/.cache/thumbnails/normal"
  clean_directory "/var/tmp"
  clean_directory "$HOME/.local/share/Trash"
  clean_directory "/var/log"
  clean_directory "/var/backups"
  clean_directory "$HOME/.cache"
  clean_directory "$HOME/Downloads"

  echo 'Fixing broken packages with dpkg...'
  dpkg --configure -a

  echo 'Cleaning old logs...'
  journalctl --vacuum-size=50M

  # Remove old snaps
  echo 'Removing old snaps...'
  snap list --all | awk '/disabled/{print $1, $3}' |
    while read -r snapname revision; do
      snap remove "$snapname" --revision="$revision"
    done

  # List all partitions size
  df -Th | sort
}

update_system
