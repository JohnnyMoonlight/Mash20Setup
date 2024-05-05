#!/bin/bash
# Install and configuration script for my Raspberry Pi Zero WH based brew process controller.
# Installs dependencies for Web20Mash and dependencies for setting up an access point.
# Downloads, builds and installs Web20Mash source code.

# GPIO pin 20 is physical pin 38 (with pins showing to the lower side 'second pin in the bottom row from the right')
PIN_NUMBER=20
IP_ADDRESS=192.168.0.1
SUBNETMASK=255.255.255.0
SSID=webmash
DEFAULT_PASSPHRASE=12345678

# Check for supported Raspberry Pi version
rev=$(awk '/^Revision/ { print $3 }' /proc/cpuinfo)
supported_platforms=('9000c1' '902120')

if [[ "${supported_platforms[@]}" =~ $rev ]]; then
   echo "Running on supported platform $rev, continuing with installation procedure."
else 
   echo "Running on not-supported platform. Aborting."
   exit 1
fi

# Install dependencies

sudo apt install debhelper libmicrohttpd-dev libmagic-dev xcftools inkscape libi2c-dev libmnl-dev libcurl4-gnutls-dev libusb-dev libow-dev sysfsutils owfs git


# Clone, build and install Web20Mash
git clone https://github.com/giggls/web20mash.git
cd web20mash
DEB_PACKAGE=web20mash dpkg-buildpackage -uc -b
sudo dpkg -i web20mash_4.2.2_armhf.deb

sudo echo "dtoverlay=w1-gpio,gpiopin=$PIN_NUMBER" | sudo tee -a /boot/config.txt
sudo cp ../conf/owfs.conf /etc/owfs.conf
sudo cp ../conf/sysfs.conf /etc/sysfs.conf
sudo cp ../conf/mashctld.conf /etc/mashctld.conf

# Setup access point
sudo apt install hostapd dnsmasq

NETWORK_CONFIG="auto wlan0
   iface wlan0 inet static
   address $IP_ADDRESS
   netmask $SUBNETMASK
   up ip link set wlan0 up"

INTERFACES_CONFIG_FILE="/etc/network/interfaces"

echo "Writing network config to interfaces file.
Config: $NETWORK_CONFIG

Interfaces file: $INTERFACES_CONFIG_FILE"


sudo echo $NETWORK_CONFIG | sudo tee -a $INTERFACES_CONFIG_FILE

ACCESS_POINT_CONFIG="country_code=DE
interface=wlan0
ssid=$SSID
channel=9
auth_algs=1
wpa=2
wpa_passphrase=$DEFAULT_PASSPHRASE
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP CCMP
rsn_pairwise=CCMP
"

ACCESS_POINT_CONFIG_FILE="/etc/default/hostapd"

echo "Writing access point config to hostapd-config.
Config: $ACCESS_POINT_CONFIG

Config file: $ACCESS_POINT_CONFIG_FILE"

sudo echo $ACCESS_POINT_CONFIG | sudo tee -a $ACCESS_POINT_CONFIG_FILE

sudo systemctl disable dhcpcd.service
sudo systemctl enable dnsmasq
sudo systemctl enable webmash
sudo systemctl enable hostapd
sudo systemctl enable ssh

sudo reboot now


