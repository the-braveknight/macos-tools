#!/bin/bash

DIR=$(dirname $0)

function fixVersion() {
    oldValue=$(/usr/libexec/PlistBuddy -c "Print $1" $2)
    newValue=$(echo $oldValue | perl -p -e 's/(\d*\.\d*(\.\d*)?)/9\1/')
    /usr/libexec/PlistBuddy -c "Set $1 '$newValue'" $2
}

if [[ ! -e $1 ]]; then
    echo "Usage: fix_info_versions.sh {Info.plist file}"
    echo "Example: fix_info_versions.sh ~/Desktop/MyKext.kext/Contents/Info.plist"
    exit 1
fi

fixVersion ":NSHumanReadableCopyright" $1
fixVersion ":CFBundleVersion" $1
fixVersion ":CFBundleGetInfoString" $1
fixVersion ":CFBundleShortVersionString" $1
