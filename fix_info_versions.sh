#!/bin/bash

DIR=$(dirname $0)

function showOptions() {
    echo "Usage: $(basename $0) [Plist file]"
    echo "Example: $(basename $0) ~/Downloads/AppleHDAInjector.kext/Contents/Info.plist"
}

function fixVersion() {
    oldValue=$(/usr/libexec/PlistBuddy -c "Print $1" $2)
    newValue=$(echo $oldValue | perl -p -e 's/(\d*\.\d*(\.\d*)?)/9\1/')
    /usr/libexec/PlistBuddy -c "Set $1 '$newValue'" $2
}

if [[ ! -e $1 ]]; then
    showOptions
    exit 1
fi

fixVersion ":NSHumanReadableCopyright" $1
fixVersion ":CFBundleVersion" $1
fixVersion ":CFBundleGetInfoString" $1
fixVersion ":CFBundleShortVersionString" $1
