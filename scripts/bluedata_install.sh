#!/usr/bin/env bash
set -e

if [[ -f /home/bluedata/ecp_installed ]]
   then
      echo "EZMERAL INSTALL: Ezmeral already installed - quitting"
      exit 0
   fi

if [[ ! -f /home/bluedata/EPIC_FILENAME ]]; then
    echo "INSTALL: Downloading installation package"
    wget -c --progress=bar -e dotbytes=10M -O "/home/bluedata/EPIC_FILENAME" "EPIC_DL_URL"
    chmod +x "/home/bluedata/EPIC_FILENAME"
else
    echo "INSTALL: Installation file already exist, skipping download"
fi

echo "INSTALL: Installing required python modules for Ezmeral"
sudo yum install -y python-pip
sudo pip install --upgrade bdworkbench
sudo pip install --quiet bs4

echo "INSTALL: Starting Ezmeral installation"
bash "/home/bluedata/EPIC_FILENAME" --skipeula --default-password admin123
/opt/bluedata/common-install/scripts/start_install.py -c CONTROLLER_IP -k no -t 60 --routable no -d internal.cloudapp.net --cin demo-hpecp
touch /home/bluedata/ecp_installed
