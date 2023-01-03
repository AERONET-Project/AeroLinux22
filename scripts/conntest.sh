
#!/bin/bash
for i in {1..3}
do

MYTIME=$(date +%s)
FILENAME=$HOME/AeroLinux22/scripts/pulse.out
wget --no-check-certificate  -q  -O $FILENAME "https://aeronet.gsfc.nasa.gov/cgi-bin/aeronet_time_new?pc_time=$MYTIME"
#Wget grabs the file with dynamically passed pc time from AEROENET server

if grep -q "$MYTIME" $FILENAME 
#Checks for matching time variable of unix timestamp in retrieved file
then
        #if it finds the heartbeat; great! 
        echo "found heartbeat to NASA AERONET server"
        break
else
        #otherwise, figure out how to get relaunch of program to try resetting modem. 
        echo "not found on $i"
fi

done

#run this three times, if no dice, issue modem hard reset.

