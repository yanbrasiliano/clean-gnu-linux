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
#
#	----------------------------------------------------------------------
#	Tested:
# BASH 5.0.3
#	ZSH 5.7.1
#
# License: GNU General Public License	
#	----------------------------------------------------------------------

#Update repositories. 
echo 'Update System...'; sleep 1
sudo apt update
echo
#Upgrade the packages that are requested. 
echo 'Upgrade System...'; sleep 1
sudo apt upgrade
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
sudo rm -vfr ~/.thumbnails/normal/*
sleep 1
sudo du -sh /var/cache/apt/archives/ 
sleep 1
sudo rm -f ~/.cache/thumbnails/normal/*
sleep 1
sudo apt clean
sleep 1
sudo rm -rf /var/tmp/*
sleep 1
sudo rm -rf "${HOME}/.local/share/Trash/"*
sleep 1
sudo du -sh /var/cache/apt/archives/
sleep 1
sudo dpkg --configure -a
echo

