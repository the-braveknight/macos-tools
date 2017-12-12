#!/bin/bash

function checkDirectory() {
    ./check_directory.sh $@
}

function fixVersion() {
    oldValue=$(/usr/libexec/PlistBuddy -c "Print $1" $2)
    newValue=$(echo $oldValue | perl -p -e 's/(\d*\.\d*(\.\d*)?)/9\1/')
    /usr/libexec/PlistBuddy -c "Set $1 '$newValue'" $2
}

checkDirectory $1
if [ $? -ne 0 ]; then
    echo "File '$1' does not exist."
    exit 1
fi

fixVersion ":NSHumanReadableCopyright" $1
fixVersion ":CFBundleVersion" $1
fixVersion ":CFBundleGetInfoString" $1
fixVersion ":CFBundleShortVersionString" $1
