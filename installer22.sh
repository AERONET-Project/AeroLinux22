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

echo "setting keymap to FREEDOM edition" 
localectl set-keyumap us 
sleep 1

echo "installing pre-reqs" 
apt-get install -y libcurl4-openssl-dev 
apt-get install -y chrony
#apt install -y ip 
#apt install -y pppd
if [[ $> 0 ]]
then
	echo "libcurl and recs failed to install, exiting."
else
	echo "Dependencies are installed, continuing with script."
fi
sleep 1 

echo "Installing Log2RAM, reduce SD wear and corruption rate" 
curl -L https://github.com/azlux/log2ram/archive/master.tar.gz | tar zxf -
cd log2ram-master
chmod +x install.sh && sudo ./install.sh
cd ..
rm -r log2ram-master
sleep 1

getent group sudo | grep -q "$user_var"
if [ $? -eq 0 ]; then
	echo "$user_var has root privileges, continuing..."
else
	echo "Adding using to root failed...Try a new username?" 1>&2
	exit 1
fi

echo "$user_var	ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

echo "workaround for dialout issues that occur sometimes for unknown reasons" 
usermod -a -G dialout $user_var
usermod -a -G tty $user_var
sleep 1
echo "De-yeeting Hologram SDK..."
mv hologram /etc/ppp/peers
mv Nova-M /etc/chatscripts
sleep 1 
echo "moved peer def and chatscript to ppp directory" 
systemctl disable ModemManager.service
echo "pest control completed; removed ModemManager"
sleep 1
echo "moving UDEV rule to final resting place"
mv 99-QualcommModem.rules /etc/udev/rules.d 
mv 00-ModemWDM.rules /etc/udev/rules.d
sleep 1
echo "Setting NTP using chrony" 
chronyc makestep 

#echo "Setting raw-ip enable perms" 
#chmod g+w /sys/class/net/wwan0/qmi/* 
#sleep 1

echo "Adding cronjobs to user's crontab"
crontab -r
cronjob1="@reboot sleep 60 && /home/$user_var/AeroLinux22/scripts/combined_pi_start_script.sh >> /home/$user_var/logs/connection.log"
cronjob2="0 0 */2 * * /home/$user_var/AeroLinux22/scripts/k7_k8_check.sh"
cronjob3="@reboot ifconfig wwan0 down; echo Y > /sys/class/net/wwan0/qmi/raw_ip; ifconfig wwan0 up" #set iface wwan0 to raw ip mode for QMI net 

{ crontab -l -u $user_var 2>/dev/null; echo "$cronjob1"; } | crontab -u $user_var -
{ crontab -l -u $user_var; echo "$cronjob2"; } | crontab -u $user_var -
{ crontab -l -u $user_var; echo "$cronjob3"; } | crontab -u $user_var -


sleep 1
echo "Building new directories..."
sleep 1

mkdir /home/$user_var/logs #Make a log file directory
mkdir /home/$user_var/cimel_logs #Make a log directory for cimel connect output
mkdir /home/$user_var/backup #For data files saved to disk
touch /home/$user_var/logs/connection.log
touch /home/$user_var/logs/modem_diagnostics.log


sleep 1
echo "Compiling Cimel software package..."
sleep 1

cd /home/$user_var/AeroLinux22/source/
cc -o ../bin/pi_ftp_upload pi_ftp_upload.c models_port.c -lm -lcurl
cc -o ../bin/models_connect_and_reset models_connect_and_reset.c models_port.c -lm -lcurl
chown -R ${user_var}: /home/$user_var/
chmod -R 777 /home/$user_var/

sleep 1
echo "==========================="
sleep 1
echo "==========================="
echo "Build complete"
echo "Please execute a reboot to hard reload daemons and kernel changes"
sudo reboot 
