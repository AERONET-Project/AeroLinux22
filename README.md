<img align="right" width="100" height="100" src="https://www.x20.org/wp-content/uploads/2015/01/NASA-logo.png"><br/>

# AeroLinux Gen 2

This software package enables Linux devices to transfer data from Cimel sun photometers via Ethernet, Wi-Fi or a Hologram Nova cellular modem.
#### Version 1.1.1 ####
 * On boot, sends a network settings message to our server via FTP
 * Watch runs on a 26 hour basis now

## Appendix

1) About
2) Local
3) Remote
4) Deployment
5) Technical Details
6) Part List


## About

The software provides fully autonomous data transfer, data uploading and data storage of the Cimel sun photometer Model 5 and TS data, and their accompanying versions (SeaPrism, Polar, etc).


The recommended set up is a Raspberry Pi Zero W 1.7 running Rasbian OS.
However, this software is lightweight and adaptable to other versions of Linux. A Debian version is strongly recommended.


Simply run the installation script and your system will be configured to run.

The data will be stored on the eMMC flash storage device as a fail safe and will be uploaded or retrieved at a later time.
## Local
This configuration is when the Linux device is connected to LAN or Wi-Fi. The Raspberry Pi can be connected to both LAN and Wi-Fi. We recommend being connected to AC power when operating with this version, as power consumption data has not been analyzed.
## Remote

The remote configuration requires a Hologram Nova modem to transfer data. These configurations should be used when the site is remote and running on solar power.
## Deployment
Your linux device must be connected to internet to clone the directory and install the required packages.
When setting up your Linux system please run the following commands.

Update the apt tool,
```bash
  sudo apt --fix-missing update -y
```
Then install git,
```bash
  sudo apt install git -y
```

To get your project up and running please clone the latest version of the software,
```bash
  sudo git clone https://github.com/AERONET-Project/AeroLinux.git
```


Run the installation script:
```bash
  cd aerolinux && sudo chmod 755 installer.sh
```
```bash
  sudo ./installer.sh
```

Please reboot the system to hard reload daemons and kernel changes.

```bash
  sudo reboot
```

Your system is now ready to go!

## Technical Details

The program will run fully autonomously, with integrated error checking and monitoring. Therefore, the system is designed as a plug and go with no configuartion required after the installation and reboot.

The system can handle unplugging and reconnecting cables, however, it is recommended to un-plug power to the Pi when you are unplugging and replugging cables.

Any updates to this GitHub respository will be propagted to your device automatically always insuring you are running the latest version of the software.

## Tech Stack

**Raspberry Pi Devices:** Zero W (1.7 and 2), Raspberry Pi 3(A, A+,B+) and Raspberry Pi 4(B).

**OS Image:** 2022-04-07-raspios-buster-lite-armhf.img - Can be downloaded [here](http://ftp.jaist.ac.jp/pub/raspberrypi/raspios_lite_armhf/images/raspios_lite_armhf-2022-04-07/) and download the following file: 2022-05-27-raspios-buster-lite-armhf.zip
There is no need to upgrade the OS image to the current version, as the updates are GUI related. 

## Part List

| Part  | Purchase URL |
| ------------- | ------------- |
| Raspberry Pi Zero W (1.7)  | [Link](https://www.raspberrypi.com/products/raspberry-pi-zero-w/)  |
| USB + Ethernet Hat & Case  | [Link](https://www.newegg.com/p/181-08AA-00003) or [Link](https://www.amazon.com/Ethernet-Case-Raspberry-Zero-Ports/dp/B09KY11X86/ref=pd_sbs_3/144-1380153-4540452?pd_rd_w=HuXHY&pf_rd_p=dfec2022-428d-4b18-a6d4-8f791333a139&pf_rd_r=SD7VDNW3ZTKQS2N5Q641&pd_rd_r=67fb36a2-57c8-43c9-821b-e96d4eba0431&pd_rd_wg=mcUmB&pd_rd_i=B09KY11X86&psc=1) |
| AC Power Supply  | [Link](https://www.adafruit.com/product/1995?gclid=Cj0KCQiA0eOPBhCGARIsAFIwTs7Y9D-CGvd56o7pYmg8GlOTs6Ii-GeUW5u5k6WKNL8dwm3qR1UXf3MaAkWaEALw_wcB)  |
| Micro SD Card  | [Link](https://www.newegg.com/sandisk-16gb-microsdhc/p/N82E16820173358)  |

***Using a cellular modem*** 
This an option for an internet connection to transfer data, the software supports the Hologram Nova [2G/3G](https://www.digikey.com/en/products/detail/hologram-inc./HOL-NOVA-U201/7915568) or [4G/LTE](https://www.digikey.com/en/products/detail/hologram-inc/HOL-NOVA-R410/9489897) (USA)

***Using solar power***
Sometimes your Cimel may be located in a remote region powered by battery. In most setups the battery will provide 12 volts. The Pi can only take 5 volts input, a DC/DC converter is required and we recommend the following due to its ease of use, [12-5V DC](https://www.newegg.com/p/2S7-01JK-0JVH6?Description=12v%20to%205v%20micro%20usb%20converter&cm_re=12v_to%205v%20micro%20usb%20converter-_-2S7-01JK-0JVH6-_-Product&quicklink=true)
