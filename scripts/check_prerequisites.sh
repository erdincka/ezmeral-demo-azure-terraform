#!/usr/bin/env bash

set -e # abort on error
set -u # abort on undefined variable

ostype=$(uname -s | tr '[:upper:]' '[:lower:]')

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

if [ -f "${HOME}/.bashrc" ] && [ ! -f "${HOME}/.bash_profile" ]; then
    profile='~/.bashrc'
else
    profile='~/.bash_profile'
fi

# Ensure python is able to find packages
REQUIRED_PATH="$(python3 -m site --user-base)/bin"
if [[ :$PATH: != *:"$REQUIRED_PATH":* ]] ; then
    tput setaf 1
    print_term_width '='
    echo "Aborting because PATH variable does not include: $REQUIRED_PATH"
    print_term_width '='
    tput sgr0
    echo
    echo "TIP: You can set the PATH for the current terminal session by running the following command:"
    echo
    echo "   export PATH=\$PATH:$REQUIRED_PATH"
    echo
    echo "To make the PATH setting permanent, add the above line to your ${profile}, e.g."
    echo
    echo "   echo 'export PATH=\$PATH:$REQUIRED_PATH' >> ${profile}"
    echo
    print_term_width '-'
    exit 1
fi

python3 -m ipcalc > /dev/null || {
    echo "I require 'ipcalc' python module, but it's not installed.  Aborting."
    echo "Please install with: 'pip3 install --user ipcalc six'"
    exit 1
}

command -v hpecp > /dev/null || {
    echo "I require 'hpecp' python module, but it's not installed.  Aborting."
    echo "Please install with: 'pip3 install --user --upgrade hpecp'"
    exit 1
}
