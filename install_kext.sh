#!/bin/bash

function install() {
    if [[ -e $1 && -d $2 ]]; then
        fileName=$(basename $1)
        echo Installing $fileName to $2
        sudo rm -Rf $2/$fileName
        sudo cp -Rf $1 $2
    fi
}

function installKext() {
    if [[ -d $1 ]]; then
        install $1 /Library/Extensions
    else
        install $(./find_kext.sh $1) /Library/Extensions
    fi
}

installKext $1
