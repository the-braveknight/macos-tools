#!/bin/bash

function installBinary() {
    fileName=$(basename $1)
    echo Installing $fileName to /usr/bin
    sudo rm -Rf /usr/bin/$fileName
    sudo cp -Rf $1 /usr/bin
}

./check_directory.sh $1
if [ $? -eq 0 ]; then
    installBinary $1
fi
