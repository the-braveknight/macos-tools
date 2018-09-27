#!/bin/bash

# Assume plist file is $plist

function printItems() {
# $1: Array name (key) in root dictionary plist
    for ((index=0; 1; index++)); do
        kext=$(/usr/libexec/PlistBuddy -c "Print :$1:$index" $plist 2>&1)
        if [[ "$kext" == *"Does Not Exist"* ]]; then
            break
        fi
        echo $kext
    done
}

function addItem() {
# $1: Array name (key) in root dictionary plist
# $2: Element
    for element in $(printInstalledItems $1); do
        if [[ "$element" == "$2" ]]; then return; fi
    done

    /usr/libexec/PlistBuddy -c "Add :$1 Array" $plist &> /dev/null
    /usr/libexec/PlistBuddy -c "Add :$1:0 String '$2'" $plist &> /dev/null
}
