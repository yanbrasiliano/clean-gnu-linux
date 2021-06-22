#/usr/bin/env bash
#
#	cleaning.sh:		script to automate the cleaning of cache, logs and files on GNU-LINUX.
#	Autor:					Yan B.S.Penalva <yanpenabr@gmail.com>
#	Site:						hellolibre.blogspot.com
#	Maintenance: 		Yan Brasiliano Silva Penalva <yanpenabr@gmail.com>
#
#----------------------------------------------------------------------
#	Automate commands for cleaning and updating the system. 
#
#	
#
#	Example of use:
#		$ ./cleaning.sh
#	
#
#----------------------------------------------------------------------
#	Historic:	
#
#	v1.0 2021.03.08, Yan Brasiliano:
#	- 	Initial version of the program, inserting functions and header. 
#	
#	V1.1 2021.06.02, Yan Brasiliano: 
#	- 	Adding new features for cleaning. 
#	----------------------------------------------------------------------
#	Tested:
# BASH 5.0.3
#	ZSH 5.7.1
#
# License: GNU General Public License	
#	----------------------------------------------------------------------

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
sudo apt autoremove --purge -y
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
sudo rm -rf /var/tmp/*
sudo du -sh /var/tmp/
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
cd /var/log/
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
echo
echo "Cleaning finished :D"

