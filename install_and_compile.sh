#!/bin/bash
# Install and configuration script for my Raspberry Pi Zero WH based brew process controller.
# Installs dependencies for Web20Mash and dependencies for setting up an access point.
# Downloads, builds and installs Web20Mash source code.

# GPIO pin 20 is physical pin 38 (with pins showing to the lower side 'second pin in the bottom row from the right')
PIN_NUMBER=20
#IP_ADDRESS=192.168.0.1
#SUBNETMASK=255.255.255.0
SSID=webmash
#DEFAULT_PASSPHRASE=12345678
WORKDIR=`pwd`

# Check for sudo user.
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 100
fi

# Check for supported Raspberry Pi version

rev=$(awk '/^Revision/ { print $3 }' /proc/cpuinfo)
supported_platforms=('9000c1' '902120')

if [[ "${supported_platforms[@]}" =~ $rev ]]; then
   echo "Running on supported platform $rev, continuing with installation procedure."
else 
   echo "Running on not-supported platform. Aborting."
   exit 1
fi

echo "Using GPIO $PIN_NUMBER as temperature sensor input pin."
#echo "Using $IP_ADDRESS as router IP."
#echo "Applying $SUBNETMASK as subnetmask."
echo "Hotspot will be available under $SSID"
#echo "Passphrase is $DEFAULT_PASSPHRASE"

# Update packages
sudo apt update -y
sudo apt upgrade -y

# Install dependencies

sudo apt install debhelper libmicrohttpd-dev libmagic-dev xcftools inkscape libi2c-dev libmnl-dev libcurl4-gnutls-dev libusb-dev libow-dev sysfsutils owfs -y

# Clone, build and install Web20Mash
git clone https://github.com/giggls/web20mash.git
cd web20mash
sudo make
sudo make install
#DEB_PACKAGE=web20mash dpkg-buildpackage -uc -b
sudo dpkg -i ../web20mash_4.2.2_armhf.deb

cd $WORKDIR

sudo echo "dtoverlay=w1-gpio,gpiopin=$PIN_NUMBER" | sudo tee -a /boot/firmware/config.txt
sudo echo "w1-gpio" | sudo tee -a /etc/modules
sudo echo "w1-therm" | sudo tee -a /etc/modules
sudo cp ./conf/owfs.conf /etc/owfs.conf
sudo cp ./conf/sysfs.conf /etc/sysfs.conf
sudo cp ./conf/mashctld.conf /etc/mashctld.conf

# Setup access point
# sudo apt install hostapd 
# Remove dnsmasq, as OS Bookworm uses dnsmasq-base
# sudo apt remove dnsmasq

#NETWORK_CONFIG="auto wlan0
#   iface wlan0 inet static
#   address $IP_ADDRESS
#   netmask $SUBNETMASK
#   up ip link set wlan0 up"

# INTERFACES_CONFIG_FILE="/etc/network/interfaces"

# echo "Writing network config to interfaces file.
# Config: `cat ./conf/ap-config/interfaces`

# Interfaces file: $INTERFACES_CONFIG_FILE"


# sudo echo "`IP_ADDRESS=$IP_ADDRESS SUBNETMASK=$SUBNETMASK envsubst < ./conf/ap-config/interfaces`" | sudo tee -a $INTERFACES_CONFIG_FILE

nmcli con add type wifi ifname wlan0 con-name $SSID autoconnect yes ssid $SSID
nmcli con modify $SSID 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared
nmcli con up $SSID

echo "cat `pwd`/banner.txt" | sudo tee -a /etc/bash.bashr

#sudo systemctl disable dhcpcd.service
#sudo systemctl enable dnsmasq
sudo systemctl enable webmash
#sudo systemctl enable hostapd
#sudo systemctl enable ssh

sudo reboot now


