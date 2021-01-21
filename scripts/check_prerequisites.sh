#!/usr/bin/env bash

set -e # abort on error
set -u # abort on undefined variable

ostype=$(uname -s | tr '[:upper:]' '[:lower:]')
downstream_repodir="./hcp-demo-env-aws-terraform"
source "${downstream_repodir}/scripts/functions.sh"

function fail {
  echo >&2 "FAIL: ${1}"
  exit 1
}

function check_command {
  command=${1}
  command -v ${command} >/dev/null 2>&1 || fail "${command} not found."
}

check_command python3
check_command pip3
check_command ssh-keygen
check_command nc
check_command curl
check_command terraform
check_command az

# New MacOS uses zsh
if [ "/bin/zsh" == "$SHELL" ]; then
  PROFILE_NAME=.zshrc
elif [ "/bin/bash" == "$SHELL" ]; then
  PROFILE_NAME=.bashrc
fi
PROFILE_PATH=$HOME/$PROFILE_NAME
# if [ -f "${HOME}/.bashrc" ] && [ ! -f "${HOME}/.bash_profile" ]; then
#     profile='~/.bashrc'
# else
#     profile='~/.bash_profile'
# fi

# Ensure python is able to find packages
REQUIRED_PATH="$(python3 -m site --user-base)/bin"
if [[ :$PATH: != *:"$REQUIRED_PATH":* ]] ; then
    echo "Your path should include ${REQUIRED_PATH}"
    echo 
    echo "add using 'echo export PATH=\$PATH:$REQUIRED_PATH >> $PROFILE_PATH'"
    echo
    exit 1
fi

python3 -m ipcalc > /dev/null || {
    echo "Installing 'ipcalc' python module"
    pip3 install --user ipcalc six
}

check_command hpecp > /dev/null || {
    echo "Installing 'hpecp' python module."
    pip3 install --user --upgrade hpecp
}
