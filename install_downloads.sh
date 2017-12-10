#!/bin/bash

# Note: This script assumes macOS 10.11 or higher. It is not expected to work with earlier versions of macOS.

settings=./settings.plist
if [ ! -e $settings ]; then
    echo No settings.plist file found! Exiting...
    exit 1
fi

os_version=$(./os_version.sh)
if [ $os_version -lt 11 ]; then
    echo Unsupported macOS version! Exiting...
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

if [ -d ./downloads ]; then
    # Extract all zip files within ./downloads folder
    extractAll ./downloads

    # Install all apps (*.app) within ./downloads folder
    installApps ./downloads

    # Install all binaries within ./downloads folder
    installBinaries ./downloads

    # Install all the kexts within ./downloads
    installKexts ./downloads
fi

# If ./install_kexts.sh script exists, run
if [ -e ./install_kexts.sh ]; then ./install_kexts.sh; fi

# Create & install AppleHDA injector kext
if [ -d Resources_$hda_codec ]; then
    ./patch_hda.sh $hda_codec
    ./install_kext.sh AppleHDA_$hda_codec.kext
else
    echo "No Resources_$hda_codec directory found; AppleHDA injector kext not installed"
fi

# Repair permissions & update kernel cahce
sudo kextcache -i /

