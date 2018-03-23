#!/bin/bash

# Fix NO_PUBKEY 16126D3A3E5C1192
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 437D05B5

# Add 'add-apt-repository' support
UBUNTU_VERSION=`lsb_release -r | grep -Eo "([0-9.]+)"`
if [ `bc -l <<< "${UBUNTU_VERSION} <= 12.04"` -eq 1 ]; then
	apt-get install -y python-software-properties
else
	apt-get install -y software-properties-common
fi

# Install common software
apt-get install -y apt-transport-https ca-certificates

apt-get install -y mtr iftop htop traceroute vim git subversion screen aria2 curl lrzsz dnsutils sshpass
apt-get install -y unzip zip p7zip-full unrar

#apt-get install -y build-essential python-dev
#apt-get install -y python3-setuptools python3-pip
apt-get install -y python-pip python-setuptools python-m2crypto python-gevent supervisor

# Install depend library for shadowsocks-libev
#autoconf libtool libssl-dev libpcre3-dev asciidoc xmlto