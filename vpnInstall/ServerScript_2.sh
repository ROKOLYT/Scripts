#!/bin/bash
set -e

NEWUSR=$1

# Add ssh key
mkdir /home/$NEWUSR/.ssh
touch /home/$NEWUSR/.ssh/authorized_keys
cat /home/$NEWUSR/vultr.pub >> /home/$NEWUSR/.ssh/authorized_keys
rm /home/$NEWUSR/vultr.pub

# Edit config

sed -i "36 s/#PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "41 s/#//" /etc/ssh/sshd_config
sed -i "44 s/#//" /etc/ssh/sshd_config
sed -i "60 s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config

# Restart ssh
sudo systemctl restart sshd
sudo apt install openvpn -y

# Install openvpn
curl -LJO https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
chmod +x openvpn-install.sh
sudo ./openvpn-install.sh

# Change config not to save logs
sed -i "35 s/3/0/" /etc/openvpn/server.conf