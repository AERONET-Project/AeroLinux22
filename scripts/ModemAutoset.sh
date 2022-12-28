#!/bin/bash
#Basic method of instancing a reset of the modem and putting it into QMI mode. 
if [ ! -e /dev/ModemWDM ]; then 
  echo -n -e "AT+CFUN=1,1 \r\n" > /dev/ModemCOM
  #Instance a reset for the modem
  echo "modem reset instanced"
else 
  echo "modem detected" #otherwise modem is detected
fi 
