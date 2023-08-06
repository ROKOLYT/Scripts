#!/bin/bash
set -e

NEWUSR=$1
PASSWD=$(openssl rand -base64 12)

sudo apt update && sudo apt upgrade -y

# Add user
useradd -m $NEWUSR
echo "$NEWUSR:$PASSWD" | chpasswd
echo "New user $NEWUSR created with password $PASSWD"

# Add user to sudoers
sed -i "$ d" /etc/sudoers
echo "$NEWUSR   ALL=(ALL) ALL" >> /etc/sudoers
echo "@includedir /etc/sudoers.d" >> /etc/sudoers

# Change to user
su $NEWUSR