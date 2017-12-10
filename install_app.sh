#!/bin/bash

function installApp() {
    if [[ -d $1 ]]; then
        fileName=$(basename $1)
        echo Installing $fileName to /Applications
        sudo rm -Rf /Applications/$fileName
        cp -Rf $1 /Applications
    fi
}

installApp $1
