#!/bin/bash

echo "recompile programs"

cd $HOME/AeroLinux22/source
cc -o ../bin/models_connect_and_reset models_connect_and_reset.c models_port.c -lm -lcurl
cc -o ../bin/pi_ftp_upload pi_ftp_upload.c models_port.c -lm -lcurl
sleep 60

modem_check=$(lsusb | grep Qualcomm) #returns string if modem was identified

if [ -z "$modem_check" ]; then #Checks if modem_check is 0/empty - i.e., no modem
        echo "A USB modem is not connected"  >> $HOME/logs/modem_diagnostics.log
        $HOME/AeroLinux22/bin/pi_ftp_upload  >> $HOME/logs/modem_diagnostics.log

else #Sees that modem_check has value and proceeds as modem is connected
        echo "A USB modem is connected" >> $HOME/logs/modem_diagnostics.log
        sudo hologram network connect  >> $HOME/logs/modem_diagnostics.log
        $HOME/AeroLinux22/bin/pi_ftp_upload  >> $HOME/logs/modem_diagnostics.log
        sudo hologram network disconnect  >> $HOME/logs/modem_diagnostics.log
fi

sleep 180


if [ -z "$modem_check" ]; then
        $HOME/AeroLinux22/bin/models_connect_and_reset local >> $HOME/logs/connection.log
else
        $HOME/AeroLinux22/bin/models_connect_and_reset hologram >> $HOME/logs/connection.log
fi

sleep 120

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
		modem_check=$(lsusb | grep Qualcomm) #returns string if modem was identified


		if [ -z "$modem_check" ]; then
        		$HOME/AeroLinux22/bin/models_connect_and_reset local >> $HOME/logs/connection.log
		else
        		$HOME/AeroLinux22/bin/models_connect_and_reset hologram >> $HOME/logs/connection.log
		fi

                sleep 13h
                now=$(date)
        fi
done
echo "Reached counter at ${now} and performed reboot" >> $HOME/logs/connection.log
sudo /sbin/shutdown -r now

