#!/usr/bin/env bash

# Define variables
LOG_FILE="$HOME/update.log"
THUMBNAILS_DIR="$HOME/.thumbnails/normal"
SLEEP_TIME=1

# Check for root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
fi


prepare_logfile () {
  echo "----------[ $(whoami) $(date) ]----------" >> "$LOG_FILE"
}

update_system () {
  echo 'Updating system...'
  sudo apt update -y
  echo 'Upgrading packages...'
  sudo apt upgrade -y
  sudo apt full-upgrade -y
  echo 'Removing unused packages...'
  sudo apt autoremove --purge -y
  echo 'Cleaning local repository...'
  sudo apt autoclean

  echo 'Cleaning system...'
  sudo rm -rf "$THUMBNAILS_DIR"/*
  sudo du -sh "$THUMBNAILS_DIR"
  sleep "$SLEEP_TIME"

  sudo rm -rf /var/cache/apt/archives/
  sudo du -sh /var/cache/apt/archives/
  sleep "$SLEEP_TIME"

  sudo rm -rf /var/cache/apt/archives/*deb
  sudo du -sh /var/cache/apt/archives/*deb
  sleep "$SLEEP_TIME"

  sudo rm -f ~/.cache/thumbnails/normal/*
  sudo du -sh ~/.cache/thumbnails/normal/*
  sleep "$SLEEP_TIME"

  sudo apt clean
  sleep "$SLEEP_TIME"

  sudo rm -rf /var/tmp/*
  sudo du -sh /var/tmp/*
  sleep "$SLEEP_TIME"

  sudo rm -rf "$HOME/.local/share/Trash/"*
  sudo du -sh "$HOME/.local/share/Trash/"*
  sleep "$SLEEP_TIME"

  echo 'Fixing broken packages with dpkg...'
  sudo dpkg --configure -a

  echo 'Cleaning old logs in /var/log...'
  sudo journalctl --vacuum-size=50M
  sudo rm -rf /var/log/*gz /var/log/*1 /var/log/*old*
  sudo du -sh /var/log
  sleep "$SLEEP_TIME"

  echo 'Cleaning old backups in /var/backups...'
  sudo rm -rf /var/backups/*gz
  sudo du -sh /var/backups/
  sleep "$SLEEP_TIME"

  echo 'Cleaning cache in /home...'
  sudo rm -rf ~/.cache/*
  sudo du -sh ~/.cache/
  sleep "$SLEEP_TIME"

  echo 'Removing old kernels...'
  sudo apt remove --purge -y $(dpkg --list | grep linux-image | awk '{ print $2 }' | sort -V | sed -n '/'`uname -r`'/q;p')
  sleep "$SLEEP_TIME"

  echo 'Removing old configuration files...'
  sudo dpkg -l | grep '^rc' | awk '{print $2}' | xargs sudo dpkg --purge
  sleep "$SLEEP_TIME"

  echo 'Removing unnecessary files from home directory...'
  rm -rf ~/Downloads/*
  rm -rf ~/.cache/*
  rm -rf ~/.local/share/Trash/*
  rm -rf ~/.thumbnails/*
  sleep "$SLEEP_TIME"
  
  # Remove old snaps
  set -eu
  snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        sudo snap remove "$snapname" --revision="$revision"
    done
    
  # List all partitions size
  df -Th | sort
}

main () {
  prepare_logfile
  update_system
}

main
