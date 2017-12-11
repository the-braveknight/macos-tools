#!/bin/bash

function installKext() {
    kextName=$(basename $1)
    echo Installing $kextName to /Library/Extensions
    sudo rm -Rf /Library/Extensions/$kextName
    sudo cp -Rf $1 /Library/Extensions
}

./check_directory.sh $1
if [ $? -eq 0 ]; then
    installKext $1
else
    ./check_directory $(./find_kext.sh $1)
    if [ $? -eq 0 ]; then
        installKext $(./find_kext.sh $1)
    fi
fi
