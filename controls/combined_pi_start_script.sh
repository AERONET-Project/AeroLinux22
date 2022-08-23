#!/bin/bash
ROOT_DIR=$HOME/aerolinux1

modem_check=$(lsusb | grep Qualcomm) #returns string if modem was identified
echo "step 1"
if [ -z "$modem_check" ]; then #Checks if modem_check is 0/empty - i.e., no modem
        echo "A USB modem is not connected"  >> $HOME/logs/modem_diagnostics.log
        $HOME/aerolinux1/controls/pi_ftp_upload  >> $HOME/logs/modem_diagnostics.log

else #Sees that modem_check has value and proceeds as modem is connected
        echo "A USB modem is connected" >> $HOME/logs/modem_diagnostics.log
        sudo hologram network connect  >> $HOME/logs/modem_diagnostics.log
        $HOME/aerolinux1/controls/pi_ftp_upload  >> $HOME/logs/modem_diagnostics.log
        sudo hologram network disconnect  >> $HOME/logs/modem_diagnostics.log
fi

sleep 180

echo "step 2"
if [ -z "$modem_check" ]; then
        $(ROOT_DIR)/cimel_connect/models_connect_and_reset local >> $HOME/logs/connection.log
else
        $(ROOT_DIR)/cimel_connect/models_connect_and_reset hologram >> $HOME/logs/connection.log
fi

sleep 120


echo "step 3"
now=$(date)

counter=0
getscript() {
  pgrep -lf ".[ /]$1( |\$)"
}
while [ $counter -lt 4 ]; do
        if getscript "models_connect_and_reset" >/dev/null; then
                echo "Cimel connect is running at ${now}" >> $HOME/logs/connection.log

                sleep 13h
                now=$(date)
        else
                echo "Cimel connect was not running at ${now}." >> $HOME/logs/connection.log
                counter=$((counter+1))
                $(ROOT_DIR)/controls/startup.sh

                sleep 13h
                now=$(date)
        fi
done

echo "Reached counter at ${now} and performed reboot" >> $HOME/logs/connection.log
sudo /sbin/shutdown -r now

