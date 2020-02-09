#!/bin/sh

set -e

if [ $(sudo fdisk -s /dev/sda2) -lt 300000000 ]; then 
    echo "$(hostname) resizing disk"
    printf "d\n2\nn\np\n2\n\n\nw\n" | sudo fdisk /dev/sda
    echo "$(hostname) rebooting..."
    nohup sudo reboot </dev/null &
else
    echo "$(hostname) no need to resize OS disk"
fi
