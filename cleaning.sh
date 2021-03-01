#/usr/bin/env bash
#
#cleaning.sh - script para automaitizar a limpeza de cache,logs e arquivos no GNU-LINUX.
#Autor:			Yan B.S.Penalva <yanpenabr@gmail.com>
#
#------------------------------------------------------
#VERSION 1.0 - Iniciando a primeira versão do script, com alguns comandos automatizando a limpeza e atualização do  sistema.
#

#Atualizar repositórios.
echo 'Update System...'; sleep 1
sudo apt update
echo
#Upgrade nos pacotes que forem solicitados.
echo 'Upgrade System...'; sleep 1
sudo apt upgrade
echo 
#Remover libs e pacotes obseletos e não mais utilizados.
echo 'Autoremove Unsed Packages ...'; sleep 1
sudo apt autoremove -y
sudo apt autoremove --purge -y
echo
#limpando o repositório local. 
echo 'Cleaning Local Repository...'; sleep 1
sudo apt autoclean
echo 
#limpeza geral de cache, temps...
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

