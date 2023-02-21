#!/bin/bash

#  -----------------------------------------------------------------
# |This script installs the necessary packages on a Linux system    |
# | It is based around QMI network pipe on Hologram NOVA  modems    |
# | The script is meant to run once, but can be reran               |
# | Author: arsenio.r.menendez@nasa.gov				                |
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
localectl set-keymap us 
sleep 1

echo "installing pre-reqs" 
apt-get install -y libcurl4-openssl-dev chrony libqmi-utils udhcpc
if [[ $> 0 ]]
then
	echo "libcurl and recs failed to install, exiting."
else
	echo "Dependencies are installed, continuing with script."
fi
sleep 1 

#echo "Installing Log2RAM, reduce SD wear and corruption rate" 
#curl -L https://github.com/azlux/log2ram/archive/master.tar.gz | tar zxf -
#cd log2ram-master
#chmod +x install.sh && ./install.sh
#cd ..
#rm -r log2ram-master
#sleep 1

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
sleep 1 
systemctl disable ModemManager.service
echo "pest control completed; removed ModemManager"
sleep 1
echo "moving UDEV rule to final resting place"
mv 99-QualcommModem.rules /etc/udev/rules.d 
mv 99-ModemWDM.rules /etc/udev/rules.d
mv chrony.conf /etc/chrony.conf
sleep 1
echo "Setting up modem sleep service on shutdown" 
chmod +x /scripts/ModemSleep.sh
mv ModemSleep.service /etc/systemd/system/
systemctl enable ModemSleep.service
chmod g+w /home/$user_var/AeroLinux22/scripts/*

echo "Setup of network start/stop symlinks"
chmod +x /home/$user_var/AeroLinux22/scripts/GSM-Up 
chmod +x /home/$user_var/AeroLinux22/scripts/GSM-Down 
echo "setting up aliases like you're Jason Bourne"
sleep 1
#echo "alias GSM-Up="bash /home/$user_var/AeroLinux22/scripts/GSM-Up"" >>  /home/$user_var/.bash_aliases
#echo "alias GSM-Down="bash /home/$user_var/AeroLinux22/scripts/GSM-Down"" >> /home/$user_var/.bash_aliases
#jank way of shutting down modem on shutdown, not optimal but it works
#echo 'alias shutdown="sudo qmicli -d /dev/ModemWDM --dms-set-operating-mode=low-power; shutdown -h now"' >>  /home/$user_var/.bash_aliases
#echo "if [ -f ~/.bash_aliases ]; then" >>  /home/$user_var/.bash_aliases
#echo ". ~/.bash_aliases" >>  /home/$user_var/.bash_aliases
#echo "fi" >>  /home/$user_var/.bash_aliases
#source  /home/$user_var/.bash_aliases
#chmod 777  /home/$user_var/.bash_aliases
# echoes into bash alias for testing

echo "Fighting a demon named Avahi" 
sudo systemctl stop avahi-daemon.socket
sudo systemctl stop avahi-daemon
sudo systemctl disable avahi-daemon.socket
sudo systemctl disable avahi-daemon 
sleep 1

echo "adding PATH variables" 
if grep -q "$HOME/AeroLinux22/scripts" $PATH #checking if already in PATH
	then #if it is, do nothing
		echo "Wait, path already there"
	else #if not, add it
		PATH="$HOME/AeroLinux22/scripts:$PATH"

fi 

echo "$HOME/AeroLinux22/scripts/GSM-Up" >> /home/$user_var/.bashrc 

sleep 1
echo "Setting NTP using chrony" 
chronyc makestep 


sleep 1 
echo "disabling DCHPCD ON WWAN0"
echo "denyinterfaces wwan0" >> /etc/dhcpcd.conf 
sleep 1


#echo "Setting raw-ip enable perms" 
#chmod g+w /sys/class/net/wwan0/qmi/* 
#sleep 1

echo "Adding cronjobs to user's crontab"
#hacky way of prepending to crontab env variables. 
crontab -r -u $user_var
echo "PATH=/home/$user_var/AeroLinux22/scripts:/usr/local/bin:/usr/bin:/bin" > tmp.cron
crontab tmp.cron 
rm -r tmp.cron 

cronjob1="@reboot sleep 60 && /home/$user_var/AeroLinux22/scripts/combined_pi_start_script.sh >> /home/$user_var/logs/connection.log"
cronjob2="0 0 */2 * * /home/$user_var/AeroLinux22/scripts/k7_k8_check.sh"
cronjob3="@reboot sleep 1 && /home/$user_var/AeroLinux22/scripts/ModemAutoset.sh" 

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
#sudo reboot 
