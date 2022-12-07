#!/bin/bash


#  =============================================================
# | Method for resetting USB hub and devices with 3x redundancy |
# | Script is used for hardware/firmware bugs of Hologram Nova  |
# | 1)Unbind and rebind the drivers to the hub controller       |
# | 2)Reset usb using usb_modeswitch			        |
# | 3)Reset usb using usbreset				        |
#  =============================================================

now=$(date)
modem_check=$(lsusb | grep Qualcomm) #Check for a modem, specifically a USB Qualcomm

if [ -z "$modem_check" ]; then
	exit 0 #this script is only needed for modem configurations
else
	echo "Modem encountered an error at $now" >> $HOME/logs/modem_diagnostics.log
	true
fi


prodid=$(lsusb | awk '$7=="Terminus"{print $6}' | cut -b 1-4) #get product id string
vendid=$(lsusb | awk '$7=="Terminus"{print $6}' | cut -b 6-9) #get vendor id string

# Reset hologram modem via command to SOC inside instead of rebinding  
sudo poff -a 
#Free up USB port for AT command and kill PPPD session 
sudo echo -n -e "AT+CFUN=1,1 \r\n" > /dev/ttyUSB2
#ACTUAL RESET HAPPENS (May require recoding of port number)
sleep 30
#Wait for modem to wake back up 

#lsusb | sudo awk '/Terminus.*Hub$/{ system("/usr/bin/usbreset " $6) }'
#Uses built in debian usbresest command, a custom version is installed in tools
#User will have to update exeucatable path to this tool
#sudo /sbin/shutdown -r now
