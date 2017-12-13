#!/bin/bash

DIR=$(dirname $0)

plist=$1

function fixVersion() {
    oldValue=$(/usr/libexec/PlistBuddy -c "Print $1" $2)
    newValue=$(echo $oldValue | perl -p -e 's/(\d*\.\d*(\.\d*)?)/9\1/')
    /usr/libexec/PlistBuddy -c "Set $1 '$newValue'" $2
}

if [[ ! -e $plist ]]; then
    echo "Usage: fix_info_versions.sh {Info.plist file}"
    echo "Example: fix_info_versions.sh ~/Desktop/MyKext.kext/Contents/Info.plist"
    exit 1
fi

fixVersion ":NSHumanReadableCopyright" $plist
fixVersion ":CFBundleVersion" $plist
fixVersion ":CFBundleGetInfoString" $plist
fixVersion ":CFBundleShortVersionString" $plist
