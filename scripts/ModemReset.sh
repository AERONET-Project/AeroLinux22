#!/bin/bash 
#Resets modem. 
echo -n -e "AT+CFUN=1,1 \r\n" > /dev/ModemCOM
