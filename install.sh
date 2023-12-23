#!/bin/bash
# Install and configuration script for my Raspberry Pi Zero WH based brew process controller.
# Installs dependencies for Web20Mash and dependencies for setting up an access point.
# Downloads, builds and installs Web20Mash source code.

# Install dependencies

sudo apt install debhelper libmicrohttpd-dev libmagic-dev xcftools inkscape libi2c-dev libmnl-dev libcurl4-gnutls-dev libusb-dev libow-dev sysfsutils owfs git

# Clone, build and install Web20Mash
git clone https://github.com/giggls/web20mash.git
cd web20mash
DEB_PACKAGE=web20mash dpkg-buildpackage -uc -b
sudo dpkg -i web20mash.deb

# Configuration
# GPIO pin 20 is physical pin 38 (with pins showing to the lower side 'second pin in the bottom row from the right')

echo "dtoverlay=w1-gpio,gpiopin=20" > /boot/config.txt
cp ./conf/owfs.conf /etc/owfs.conf
cp ./conf/sysfs.conf /etc/sysfs.conf
cp ./conf/mashctld.conf /etc/mashctld.conf

sudo apt install procps iproute2 dnsmasq iptableshostapd iw iwconfig
# Set hostname
# Configure AP
git clone git@github.com:garywill/linux-router.git
# Accordig to docs sth like
# With or without password?
# --no-virt uses physical interface, not virtual
sudo lnxrouter -n --ap wlan0 MyAccessPoint -g 192.168.2.1
