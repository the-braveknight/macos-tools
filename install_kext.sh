#!/bin/bash

DIR=$(dirname $0)

function installKext() {
    kextName=$(basename $1)
    echo Installing $kextName to /Library/Extensions
    sudo rm -Rf /Library/Extensions/$kextName
    sudo cp -Rf $1 /Library/Extensions
}

$DIR/check_directory.sh $1
if [ $? -eq 0 ]; then
    installKext $1
else
    $DIR/check_directory $($DIR/find_kext.sh $1)
    if [ $? -eq 0 ]; then
        installKext $($DIR/find_kext.sh $1)
    fi
fi
