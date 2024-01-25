#!/bin/bash

# Script to set up a server with specific configurations

# Define username for the new admin account and github name for pubkey
username="bonzadm"
github="RobertKalnins"
export github

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# 1. Create admin user with a random password
password=$(openssl rand -base64 12)
adduser $username --gecos "" --disabled-password
echo "$username:$password" | chpasswd
usermod -aG sudo $username

# 2. Set up UFW (Uncomplicated Firewall)
ufw default deny incoming
ufw default allow outgoing
ufw allow 22
ufw enable

# 3. Display then expire the user's password to force a change on next login
echo "Temporary password for $username user: $password"
echo "$username user must change their password now."
passwd --expire $username

# 4. Force password change and import public SSH key as the new user
su - $username -c 'ssh-import-id gh:$github'

# 5. Lock down SSH
sed -i '/^#PermitRootLogin/s/^#//' /etc/ssh/sshd_config
sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config
sed -i '/^#PasswordAuthentication/s/^#//' /etc/ssh/sshd_config
sed -i '/^PasswordAuthentication/s/yes/no/' /etc/ssh/sshd_config
systemctl restart sshd

echo "Server setup completed."
sudo su - $username