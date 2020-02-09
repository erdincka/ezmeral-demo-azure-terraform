#!/bin/bash

set -e 

sudo xfs_growfs /dev/sda2

yum check-update

if [ $? == 100 ]; then
    echo "Installing updates"
    sudo yum -y update
    nohup sudo reboot </dev/null &
    echo "$(hostname) rebooting..."
else
    echo "No updates pending..."
fi
