#!/bin/bash

set -e

if [[ ! -f initialized ]]; then
    echo PASSWORD | sudo passwd --stdin bluedata
    sudo yum install -y xrdp git golang @Mate
    ln -sf /usr/bin/mate-session ~/.xsession
    sudo systemctl enable --now xrdp
    gsettings set org.mate.screensaver lock-enabled false
else
    echo RDP host already initialized, skipping...
fi

if [[ ! -d minica ]]; then
    git clone https://github.com/jsha/minica.git
    cd minica/
    go build
    sudo mv minica /usr/local/bin
    cd ~
    minica -domains DOMAINS -ip-addresses IPS -ca-cert cacert.pem -ca-key cakey.pem
else
    echo Skipping CA certificate setup
fi

touch initialized
echo Finished initializing RDP host