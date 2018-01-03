#!/bin/bash

acpi_repo=https://github.com/RehabMan/OS-X-Clover-Laptop-Config/raw/master/hotpatch

function showOptions() {
    echo "-p,  Provide plist (array) with names of SSDTs."
    echo "-n,  Provide name of SSDT file."
    echo "-o,  Provide output directory."
    echo "-h,  Show this help message."
}

function plistError() {
    echo "Error: Plist file corrupted or invalid."
}

function ssdtError() {
    echo "Usage: hotpatch_download.sh -n {name of SSDT}"
    echo "Example: hotpatch_download.sh -n SSDT-PNLF.dsl"
}

function download() {
# $1: Output directory
# $2: Hotpatch SSDT name
    echo "Downloading $2..."
    url=$acpi_repo/$2
    curl --progress-bar --location $url --output $1/$2
}

function plistDownload() {
# $1: Output directory
# $2: Plist file
    directory=$1/$(basename $2 .plist)
    if [[ ! -d $directory ]]; then mkdir -p $directory; fi
    for ((index=0; 1; index++)); do
        ssdt=$(/usr/libexec/PlistBuddy -c "Print ':$index'" $2 2>&1)
        if [[ "$ssdt" == *"Does Not Exist"* ]]; then break; fi
        download $directory $ssdt
    done
}

if [[ ! -n $@ ]]; then showOptions; exit 1; fi

while getopts n:p:o:h option; do
    case $option in
        n)
            ssdt=$OPTARG
        ;;
        p)
            plist=$OPTARG
        ;;
        o)
            outputDirectory=$OPTARG
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

if [[ ! -e $outputDirectory ]]; then outputDirectory=Downloads; fi

if [[ -n $plist ]]; then
    if [[ "$(plutil $plist)" != *"OK"* ]]; then plistError; exit 1; fi
    plistDownload $outputDirectory $plist
else
    if [[ ! -n $ssdt ]]; then ssdtError; exit 1; fi
    download $outputDirectory $ssdt
fi
