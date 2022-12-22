#!bin/bash 

curl -I -s --connect-timeout 5 --max-time 10 http://www.msftncsi.com/ncsi.txt | grep "HTTP/1.1 200 OK"

#run this three times, if no dice, issue modem hard reset.

