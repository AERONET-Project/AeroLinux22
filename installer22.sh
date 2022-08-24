#!/bin/bash

#  -----------------------------------------------------------------
# |This script installs the necessary packages on a Linux system    |
# | It includes a Python installation to operate a modem	    |
# | The script is meant to run once, running again will add new user|
# | Author: anthony.d.larosa@nasa.gov				    |
#  -----------------------------------------------------------------
user_var=$(logname)

if [ `id -u` -ne 0 ]; then
	echo "Please execute this installer script with sudo, exiting.."
	exit 1
fi

echo "Setting system's timezone to UTC."
timedatectl set-timezone Etc/UTC
sleep 1


apt-get install -y libcurl4-openssl-dev
if [[ $> 0 ]]
then
	echo "libcurl failed to install, exiting."
else
	echo "libcurl is installed, continuing with script."
fi

echo "Downloading Hologram SDK..."
curl -L hologram.io/python-install | bash

if [[ $> 0 ]]
then
	echo "SDK failed installation, re-running"
	curl -L hologram.io/python-install | bash
else
	echo "Sucessfully installed Hologram SDK"
fi
curl -L hologram.io/python-install | bash

getent group sudo | grep -q "$user_var"
if [ $? -eq 0 ]; then
	echo "$user_var has root privileges, continuing..."
else
	echo "Adding using to root failed...Try a new username?" 1>&2
	exit 1
fi



echo "$user_var	ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "Adding cronjobs to user's crontab"
cronjob1="@reboot sleep 60 && /home/$user_var/AeroLinux22/scripts/combined_pi_start_script.sh >> /home/$user_var/logs/connection.log"
cronjob4="0 0 */2 * * /home/$user_var/AeroLinux22/scripts/k7_k8_check.sh"


{ crontab -l -u $user_var 2>/dev/null; echo "$cronjob1"; } | crontab -u $user_var -
{ crontab -l -u $user_var; echo "$cronjob4"; } | crontab -u $user_var -

sleep 2
echo "Building new directories..."
sleep 2

mkdir /home/$user_var/logs #Make a log file directory
mkdir /home/$user_var/cimel_logs #Make a log directory for cimel connect output
mkdir /home/$user_var/backup #For data files saved to disk
touch /home/$user_var/logs/connection.log
touch /home/$user_var/logs/modem_diagnostics.log


sleep 2
echo "Compiling Cimel software package..."
sleep 2

cd /home/$user_var/AeroLinux22/source/
cc -o ../bin/pi_ftp_upload pi_ftp_upload.c models_port.c -lm -lcurl
cc -o ../bin/models_connect_and_reset models_connect_and_reset.c models_port.c -lm -lcurl
chown -R ${user_var}: /home/$user_var/
chmod -R 777 /home/$user_var/

sleep 2
echo "==========================="
sleep 2
echo "==========================="
echo "Build complete"
echo "Please execute a reboot to hard reload daemons and kernel changes"
