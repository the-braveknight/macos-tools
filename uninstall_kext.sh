#!/bin/bash

function uninstallKext() {
    sudo rm -Rf $(./find_kext.sh $1 /System/Library/Extensions /Library/Extensions)
}

uninstallKext $1
