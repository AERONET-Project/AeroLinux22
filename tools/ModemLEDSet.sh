#!/bin/bash 
echo "Opening serial port to toggle GPIO pins on"
echo -n -e  "AT.UGPIOC=23,10\r\n" > /dev/ModemCOM
echo -n -e  "AT.UGPIOC=16,2\r\n" > /dev/ModemCOM
echo "Done!" 
