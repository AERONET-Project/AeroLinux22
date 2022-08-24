#!/bin/bash

cd $HOME/AeroLinux22
if git fetch origin main --progress 2>&1 | grep -q "Enumerating"; then
  echo "Update found from GitHub, rebooting and then will recompile"
  git fetch origin main
  git reset --hard origin/main
  sleep 2
  echo "======================="
  echo "======================="
  sleep 3
  
 
  echo "Setting permissions"
  chmod -R 777 $HOME/AeroLinux22/
  chmod -R 777 $HOME/AeroLinux22/scripts
  chmod -R 777 $HOME/AeroLinux22/tools
  chmod -R 777 $HOME/AeroLinux22/source
  chmod -R 777 $HOME/AeroLinux22/bin
  chown -R ${USER}:${USER} $HOME/AeroLinux22/
  sudo reboot 
fi
