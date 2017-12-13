#!/bin/bash

DIR=$(dirname $0)

app=$1

function installApp() {
    appName=$(basename $1)
    echo Installing $appName to /Applications
    sudo rm -Rf /Applications/$appName
    cp -Rf $1 /Applications
}

if [[ ! -d $app ]]; then
    echo "Usage: install_app.sh {app to install}"
    echo "Example: install_app.sh ~/Downloads/MaciASL.app"
    exit 1
fi

installApp $app
