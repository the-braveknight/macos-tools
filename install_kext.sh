#!/bin/bash

DIR=$(dirname $0)

kext=$1

function installKext() {
    kextName=$(basename $1)
    echo Installing $kextName to /Library/Extensions
    sudo rm -Rf /Library/Extensions/$kextName
    sudo cp -Rf $1 /Library/Extensions
}

if [[ ! -d $kext ]]; then
    echo "Usage: install_kext.sh {kext to install}"
    echo "Example: install_kext.sh ~/Desktop/AppleHDAInjector.kext"
    exit 1
fi

installKext $kext
