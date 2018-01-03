#!/bin/bash

# Note: This script assumes macOS 10.11 or higher. It is not expected to work with earlier versions of macOS.

DIR=$(dirname $0)

downloads_dir=Downloads

function showOptions() {
    echo "-p,  Provide plist (array) of kext exceptions."
    echo "-e,  Provide string of kext exceptions."
    echo "-h,  Show this help message."
}

function plistError() {
    echo "Error: Plist file invalid or corrupted."
}

while getopts e:p:h option; do
    case $option in
        p)
            plist=$OPTARG
        ;;
        e)
            string=$OPTARG
        ;;
        h)
            showOptions
            exit 0
        ;;
        \?)
            showOptions
            exit 1
        ;;
    esac
done

if [[ -n $plist ]]; then
    if [[ "$(plutil $plist)" != *"OK"* ]]; then plistError; exit 1; fi
    exceptions=$(/usr/libexec/PlistBuddy -c 'Print :' $plist 2>&1 | sed 's/.* //' | tr -d '{}')
elif [[ -n $string ]]; then
    exceptions=$string
fi

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
