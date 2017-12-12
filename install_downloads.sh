#!/bin/bash

# Note: This script assumes macOS 10.11 or higher. It is not expected to work with earlier versions of macOS.

settings=./settings.plist
./check_directory.sh $settings
if [ $? -ne 0 ]; then
    echo No settings.plist file found! Exiting...
    exit 1
fi

hda_codec=$(/usr/libexec/PlistBuddy -c 'Print :Codec' $settings 2>&1)
exceptions=$(/usr/libexec/PlistBuddy -c 'Print :Exceptions' $settings 2>&1 | sed 's/.* //' | tr -d '{}')

function check() {
    for exception in $exceptions; do
        if [[ "$1" == *"$exception"* ]]; then
            return 1
        fi
    done
    return 0
}

function extract() {
    filePath=${1/.zip/}
    rm -Rf $filePath
    unzip -q $1 -d $filePath
    rm -Rf $filePath/__MACOSX
}

function extractAll() {
    for zip in $(find $@ -name *.zip); do
        extract $zip
    done
}

function installApps() {
    for app in $(find $@ -name *.app); do
        ./install_app.sh $app
    done
}

function installBinaries() {
    for bin in $(find $@ -type f -perm -u+x -not -path \*.kext/* -not -path \*.app/* -not -path \*/Debug/*); do
        check $bin
        if [ $? -eq 0 ]; then
            ./install_binary.sh $bin
        fi
    done
}

function installKexts() {
    for kext in $(./find_kext.sh "*.kext" $@); do
        check $kext
        if [ $? -eq 0 ]; then
            ./install_kext.sh $kext
        fi
    done
}

./check_directory.sh ./downloads
if [ $? -eq 0 ]; then
    # Extract all zip files within ./downloads folder
    extractAll ./downloads

    # Install all apps (*.app) within ./downloads folder
    installApps ./downloads

    # Install all binaries within ./downloads folder
    installBinaries ./downloads

    # Install all the kexts within ./downloads
    installKexts ./downloads
fi

# Repair permissions & update kernel cahce
sudo kextcache -i /
