#!/bin/bash

DIR=$(dirname $0)

function installBinary() {
    fileName=$(basename $1)
    echo Installing $fileName to /usr/bin
    sudo rm -Rf /usr/bin/$fileName
    sudo cp -Rf $1 /usr/bin
}

if [[ ! -e $1 ]]; then
    echo "Usage: install_binary.sh {binary to install}"
    echo "Example: install_binary.sh ~/Downloads/hda-verb"
    exit 1
fi

for bin in $@; do
    installBinary $bin
done
