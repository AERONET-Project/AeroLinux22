# this script creates a power button  on pin 26 and shuts down the
#pi if the UPS battery gets to low

import smbus
import time
import os
import RPi.GPIO as GPIO
import datetime
import Adafruit_ADS1x15

time.sleep(3)
start=time.time()
batt_check_interval=600#external battery will be checekd every (600 seconds) 10min

# update system time through HTTP port with google.com since NTP port is blocked on many campus networks
os.system('''sudo date -s "$(curl -s --head http://google.com | grep ^Date: | sed 's/Date: //g')"''')

#open External battery coltage log
f= open("/home/test_6/UPS/Ext_Batt_Voltage_Log.txt", "a")
fi=open("/home/test_6/UPS/UPS_log.txt", "a")
# Create an ADS1115 ADC (16-bit) instance.
adc = Adafruit_ADS1x15.ADS1115()

#ADC gain
GAIN = 2/3

#parameters used for ADC mapping from 5V to 12V
adcMax=24950
adcMin=0
battMax=14.66
battMin=0
adcRange=adcMax-adcMin
battRange=battMax-battMin

#set up GPIO
power_btn=4
power_LED=17
piOnStatus= 6
USBpowerStatus=5
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(power_btn, GPIO.IN, pull_up_down=GPIO.PUD_UP) #power btn
GPIO.setup(power_LED, GPIO.OUT, initial=GPIO.HIGH) #for power indication LED
GPIO.setup(piOnStatus,GPIO.OUT, initial=GPIO.HIGH)# set this pin high so ATtiny watchdog knows pi is powered on
GPIO.setup(USBpowerStatus, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)#to read if USB power cable is connected and had power coming in
#start comm and read power levels from UPS HAT
addr=0x10 #ups i2c address
bus=smbus.SMBus(1) #i2c-1
try:
        vcellH=bus.read_byte_data(addr,0x03)#
except OSError:
        time.sleep(3)
        vcellH=bus.read_byte_data(addr,0x03)##
vcellL=bus.read_byte_data(addr,0x04)
socH=bus.read_byte_data(addr,0x05)
socL=bus.read_byte_data(addr,0x06)
lipo_shutdown = True
lipo_threshold =float(50.0)
ext_shutdown = False
ext_threshold =11.0

def ADCmapping(adcReading):
     battVolt=(((adcReading-adcMin)*battRange)/adcRange)+battMin
     return round(battVolt,1)

def checkAndLogExtBatt():
        # Read all the ADC channel values in a list.
        #values = [0]*4
        #read ADC channel 1

        try:
            adcReading= adc.read_adc(1, gain=GAIN)
            battVolt=ADCmapping(adcReading)
            now=datetime.datetime.now()
            entry= (now.strftime("%Y-%m-%d %H:%M:%S")+" - " + str(battVolt) + "\n")
            #print (entry)
            f.write(entry)
            f.flush()
        except OSError:
            print("ERROR: Coupd not connect to Voltage monitoring ADC")
        
        

def readInputFile():
        
    global lipo_threshold
    global lipo_shutdown
    global ext_shutdown
    global ext_threshold
    fil= open("/home/test_6/UPS/AEROLINUX_UPS_CONFIG.txt", "r")
    #print("input file read")


    # read and ignore file header
    s=fil.readline()
    #read and ignore empty line
    s=fil.readline()


    #get lipo boolean
    s=fil.readline()
    l=s.split(':')
    l[1]=l[1].strip()
    if l[1].lower()=="false":
        lipo_shutdown= False
    else:
        lipo_shutdwon=True

    print("LiPo Shutdown:" + str(lipo_shutdown))

    #get lipo threshold
    s=fil.readline()
    l=s.split(':')
    l[1]=l[1].strip('%\n')
    lipo_threshold=float(l[1])
    print("LiPo Threshold:" + str(lipo_threshold))

    #read and ignore empty line
    s=fil.readline()
    #get ext batt bool
    s=fil.readline()
    l=s.split(':')
    l[1]=l[1].strip()
    if l[1].lower()=="false":
        ext_shutdown= False
    else:
        ext_shutdown=True


    print("External battery Shutdown:" + str(ext_shutdown))
    s=fil.readline()
    l=s.split(':')
    ext_threshold=float(l[1].strip('vV\n'))
    print("External Battery Threshold:" + str(ext_threshold))


    fil.close

    #s=int((f.readline()))


#txt file for setting UPS battery cut off threshold
#f= open("/home/test_5/AEROLINUX_UPS/UPS_SHUTDOWN_THRESHOLD.txt", "r")
readInputFile()
#f= open("UPS_SHUTDOWN_THRESHOLD.txt", "r")




def btn_Shutdown(channel):
    now=datetime.datetime.now()
    entry= (now.strftime("%Y-%m-%d %H:%M:%S")+" - " + "POWER BUTTON PUSHED-SYSTEM SHUTTING DOWN" + "\n")
    #print (entry)
    fi.write(entry)
    fi.flush()
    print(entry)
    time.sleep(5)
    os.system("sudo shutdown -h now")


def Shutdown():
    now=datetime.datetime.now()
    entry= (now.strftime("%Y-%m-%d %H:%M:%S")+" - " + "BATTERY BELOW THRESHOLD AND NO AC POWER DETECTED-SYSTEM SHUTTING DOWN" + "\n")
    #print (entry)
    fi.write(entry)
    fi.flush()
    print(entry)
    print("SHUTTING DOWN")
    time.sleep(5)
    os.system("sudo shutdown -h now")

#power btn
GPIO.add_event_detect(power_btn, GPIO.FALLING, callback=btn_Shutdown, bouncetime=2000)

#Make entry in log upon boot up
socH=bus.read_byte_data(addr,0x05)
socL=bus.read_byte_data(addr,0x06)
electricity=((socH<<8)+socL)*0.003906 #current electric quantity percentage
now=datetime.datetime.now()
entry= (now.strftime("%Y-%m-%d %H:%M:%S")+" - " + "SYSTEM POWERED ON.  LIPO LEVEL=%.2f"%electricity + "\n")
    #print (entry)
fi.write(entry)
fi.flush()


while 1:
    #read battery level
    socH=bus.read_byte_data(addr,0x05)
    socL=bus.read_byte_data(addr,0x06)
    electricity=((socH<<8)+socL)*0.003906 #current electric quantity percentage
    
    #print battery percentage
    #print("battery percentage=%.2f"%electricity)
    #print (lipo_threshold)
    
    if electricity<lipo_threshold:
        #print("UPS batery below lipo_threshold")
        if not GPIO.input(USBpowerStatus):
            #print("UPS battery is below lipo_threshold and no external power source detected")
            Shutdown()
        else:
            #print("External power detected")
            pass
    now=time.time()
    elapsed=now-start
    elapsed= round(elapsed,0)
    #print (elapsed)
    trigger=bool(elapsed%batt_check_interval)# will return 0 aka False when elapsed time is divisible by the time intervale ie once every interval
    
    #time.sleep(1)#print(trigger)
    if not trigger:
        checkAndLogExtBatt()        
    time.sleep(5)


