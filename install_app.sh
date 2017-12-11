#!/bin/bash

function installApp() {
    appName=$(basename $1)
    echo Installing $appName to /Applications
    sudo rm -Rf /Applications/$appName
    cp -Rf $1 /Applications
}

./check_directory.sh $1
if [ $? -eq 0 ]; then
    installApp $1
fi
