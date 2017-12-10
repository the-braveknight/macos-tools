#!/bin/bash

function installBinary() {
    if [[ -e $1 ]]; then
        fileName=$(basename $1)
        echo Installing $fileName to /usr/bin
        sudo rm -Rf /usr/bin/$fileName
        sudo cp -Rf $1 /usr/bin
    fi
}

installBinary $1
