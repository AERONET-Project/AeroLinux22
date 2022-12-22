#GSM network startup script for Hologram modems over QMI
#Written by Arsenio Menendez

#Switch modem mode into online
sudo qmicli -d /dev/ModemWDM --dms-set-operating-mode=online; 
#Stop any existing network pipe
sudo qmi-network /dev/ModemWDM stop; 
sleep 1; 
#Down the WWAN interface
sudo ifconfig wwan0 down; 
sleep 2; 
#Set mode to raw-ip instead of ethernet
sudo qmicli -d /dev/ModemWDM --set-expected-data-format=raw-ip; 
sleep 1;
#Up the WWAN interface
ifconfig wwan0 up;
sleep 1; 
#Start up and connect the IP pipe
sudo qmi-network /dev/ModemWDM start; 
sleep 2; 
#Handshake and get issued a DHCP address
sudo udhcpc -i wwan0; 
