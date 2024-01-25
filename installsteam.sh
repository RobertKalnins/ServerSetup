#!/bin/bash

# Script to install steam

# Housekeeping - Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# 1. Install dependencies and SteamCMD
add-apt-repository -y multiverse
dpkg --add-architecture i386
apt update
apt install -y steamcmd

# 2. Create steam user with a random password
password=$(openssl rand -base64 12)
adduser steam --gecos "" --disabled-password
echo "steam:$password" | chpasswd

# 3. Run steamcmd as the steam user
su - steam -c 'steamcmd +quit'

# 4. Print then expire the password and switch to the user
echo "Temporary password for steam user: $password"
echo "Steam user must change their password now."
passwd --expire steam
su - steam