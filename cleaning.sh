#!/usr/bin/env bash

# Define variables
LOG_FILE="$HOME/update.log"
THUMBNAILS_DIR="$HOME/.thumbnails/normal"
SLEEP_TIME=1

# Function to check for root permissions
check_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
  fi
}

# Function to log messages
log_message() {
  echo "----------[ $(whoami) $(date) ]----------" >>"$LOG_FILE"
}

# Function to clean directories
clean_directory() {
  local dir=$1
  echo "Cleaning $dir..."
  sudo rm -rf "${dir:?}"/* # The :? ensures that the variable is not empty
  sudo du -sh "$dir"
  sleep "$SLEEP_TIME"
}

# Function to update the system
update_system() {
  check_root
  log_message

  echo 'Updating system...'
  if ! sudo apt update -y; then
    echo "Failed to update package lists, exiting."
    exit 1
  fi

  echo 'Upgrading packages...'
  sudo apt upgrade -y
  sudo apt full-upgrade -y

  echo 'Removing unused packages...'
  sudo apt autoremove --purge -y

  echo 'Cleaning local repository...'
  sudo apt autoclean

  clean_directory "$THUMBNAILS_DIR"
  clean_directory "/var/cache/apt/archives"
  clean_directory "~/.cache/thumbnails/normal"
  clean_directory "/var/tmp"
  clean_directory "$HOME/.local/share/Trash"
  clean_directory "/var/log"
  clean_directory "/var/backups"
  clean_directory "~/.cache"

  echo 'Fixing broken packages with dpkg...'
  sudo dpkg --configure -a

  echo 'Cleaning old logs...'
  sudo journalctl --vacuum-size=50M

  echo 'Removing old kernels...'
  # safer approach to remove old kernels
  sudo apt autoremove --purge

  echo 'Removing old configuration files...'
  sudo dpkg -l | grep '^rc' | awk '{print $2}' | xargs -r sudo dpkg --purge

  echo 'Removing unnecessary files from home directory...'
  clean_directory ~/Downloads

  # Remove old snaps
  snap list --all | awk '/disabled/{print $1, $3}' |
    while read -r snapname revision; do
      sudo snap remove "$snapname" --revision="$revision"
    done

  # List all partitions size
  df -Th | sort
}

main() {
  update_system
}

main
