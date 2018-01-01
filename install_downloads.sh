#!/bin/bash

# Note: This script assumes macOS 10.11 or higher. It is not expected to work with earlier versions of macOS.

DIR=$(dirname $0)

downloads_dir=Downloads

if [[ ! -e $1 ]]; then
    echo "Usage: install_downloads.sh {kext exceptions plist file}"
    echo "Example: install_downloads.sh Exceptions.plist"
    exit 1
elif [[ $(plutil $1) != *"OK"* ]]; then
    echo "Error: Plist file corrupt or invalid."
    exit 1
fi

exceptions=$(/usr/libexec/PlistBuddy -c 'Print :' $1 2>&1 | sed 's/.* //' | tr -d '{}')

function check() {
    for exception in $exceptions; do
        if [[ "$1" == *"$exception"* ]]; then
            return 1
        fi
    done
    return 0
}

function unarchiveAll() {
    for zip in $(find $@ -name *.zip); do
        $DIR/unarchive_file.sh $zip
    done
}

function installApps() {
    for app in $(find $@ -name *.app); do
        $DIR/install_app.sh $app
    done
}

function installBinaries() {
    for bin in $(find $@ -type f -perm -u+x -not -path \*.kext/* -not -path \*.app/* -not -path \*/Debug/*); do
        check $bin
        if [ $? -eq 0 ]; then
            $DIR/install_binary.sh $bin
        fi
    done
}

function installKexts() {
    for kext in $($DIR/find_kext.sh "*.kext" $@); do
        check $kext
        if [ $? -eq 0 ]; then
            $DIR/install_kext.sh $kext
        fi
    done
}

if [[ -d $downloads_dir ]]; then
    # Extract all zip files within downloads folder
    unarchiveAll $downloads_dir

    # Install all apps (*.app) within downloads folder
    installApps $downloads_dir

    # Install all binaries within downloads folder
    installBinaries $downloads_dir

    # Install all the kexts within downloads folder
    installKexts $downloads_dir
fi
