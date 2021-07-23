#/usr/bin/env bash


export PATH=$PATH:/home/blackowl

LOG_FILE="/home/blackowl/update.log"
REDIRECT_LOG_FILE="1>> $LOG_FILE 2>&1"

# ------- FUNCTIONS -------

preparelogfile () {

  # Insert a simple header to the log file with the 
	  echo "----------[ $(whoami) $(date) ]----------" >> $LOG_FILE

}

updatesystem () {
#Update repositories. 
echo 'Update System...'; sleep 1
sudo apt update -y
echo
#Upgrade the packages that are requested. 
echo 'Upgrade System...'; sleep 1
sudo apt upgrade -y
sudo apt full-upgrade -y
echo 
#Remove obsolete and no longer used libs and packages. 
echo 'Autoremove Unsed Packages ...'; sleep 1
sudo apt autoremove -y
echo
#cleaning up the local repository. 
echo 'Cleaning Local Repository...'; sleep 1
sudo apt autoclean
echo 
#general cache clearing, temps, etc.
echo 'General Cleaning of the system...'; sleep 1
sudo rm -rf ~/.thumbnails/normal/*
sudo du -sh ~/.thumbnails/normal/*
echo
sleep 1
sudo rm -rf /var/cache/apt/archives/
sudo du -sh /var/cache/apt/archives/
echo
sleep 1
sudo rm -rf /var/cache/apt/archives/*deb
sudo du -sh /var/cache/apt/archives/*deb
echo
sleep 1
sudo rm -f ~/.cache/thumbnails/normal/*
sudo du -sh ~/.cache/thumbnails/normal/*
echo
sleep 1
sudo apt clean
echo
sleep 1
sudo rm -rf /var/tmp/*
sudo du -sh /var/tmp/*
echo
sleep 1
sudo rm -rf "${HOME}/.local/share/Trash/"*
sudo du -sh "${HOME}/.local/share/Trash/"*
echo
sleep 1
echo "Fixing broken packages with dpkg!"
sleep 1
sudo dpkg --configure -a
echo
echo "Cleaning /var/log old logs"
sudo rm -rf /var/log/*
sleep 1
sudo find | sudo grep gz$|sudo xargs rm -rf 
sudo find | sudo grep 1$|sudo xargs rm -rf 
sudo find | sudo grep old$|sudo xargs rm -rf
sudo du -sh /var/log
sleep 2 
echo
echo "Cleaning old backups" 
sudo rm -rf /var/backups/*gz
sudo du -sh /var/backups/
echo 
sleep 2
echo
echo "Cleaning cache /home"
sudo rm -rf ~/.cache/*
sudo du -sh ~/.cache/
sleep 2
}

main () {
	preparelogfile
	updatesystem
}

# ------------------------------

# ----- EXECUTION ---- #

main

# -------------------- #
