#!/bin/bash

tbk=~/Library/the-braveknight
if [[ ! -d $tbk ]]; then mkdir $tbk; fi
installed=$tbk/org.the-braveknight.installed.plist

function printInstalledElements() {
# $1: Array name (key) in root dictionary plist
    for ((index=0; 1; index++)); do
        kext=$(/usr/libexec/PlistBuddy -c "Print :$1:$index" $installed 2>&1)
        if [[ "$kext" == *"Does Not Exist"* ]]; then
            break
        fi
        echo $kext
    done
}

function addInstalledElement() {
# $1: Array name (key) in root dictionary plist
# $2: Element
    for element in $(printInstalledElements $1); do
        if [[ "$element" == "$2" ]]; then return; fi
    done

    /usr/libexec/PlistBuddy -c "Add :$1 Array" $installed &> /dev/null
    /usr/libexec/PlistBuddy -c "Add :$1:0 String '$2'" $installed &> /dev/null
}
