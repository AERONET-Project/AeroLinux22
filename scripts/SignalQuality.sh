#!/bin/bash 

$var = (sudo qmicli -p -d /dev/ModemWDM --nas-get-signal-info | grep RSSI | grep -o -E '[0-9]+' )

if $var >=94 && $var <= 109 
then echo "Marginal"
elif $var >=85 && $var <94 
then echo "OK"
elif $var >=75 && $var <85 
then echo "Good"
elif $var >=53 && $var <75 
then echo "Excellent"

else
echo "NO SIGNAL; Dial ET to phone home at 8675301"
