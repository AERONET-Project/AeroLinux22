#GSM network shutdown script for Hologram modems over QMI
#Written by Arsenio Menendez

#Stop any existing network pipe
sudo qmi-network /dev/ModemWDM stop; 
sleep 2; 
#Down the WWAN interface
ifconfig wwan0 down;
sleep 1; 
#Switch modem mode into low power
sudo qmicli -d /dev/ModemWDM --dms-set-operating-mode=low-power; 
