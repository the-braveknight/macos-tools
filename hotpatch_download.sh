#!/bin/bash

acpi_repo=https://github.com/RehabMan/OS-X-Clover-Laptop-Config/raw/master/hotpatch

function download() {
# $1: Output directory
# $2: Hotpatch SSDT name
    echo "Downloading $2..."
    url=$acpi_repo/$2
    curl --progress-bar --location $url --output $1/$2
}

function plistDownload() {
    directory=Downloads/$(basename $1 .plist)
    if [[ ! -d $directory ]]; then mkdir -p $directory; fi
    for ((index=0; 1; index++)); do
        ssdt=$(/usr/libexec/PlistBuddy -c "Print ':$index'" $1 2>&1)
        if [[ "$ssdt" == *"Does Not Exist"* ]]; then break; fi
        download $directory $ssdt
    done
}

if [[ ! -e $1 ]]; then
    echo "Usage: hotpatch_download.sh {plist file}"
    echo "Example: hotpatch_download.sh ~/Desktop/Hotpatch.plist"
    exit 1
elif [[ $(plutil $1) != *"OK"* ]]; then
    echo "Error: Plist file corrupt or invalid."
    exit 1
fi

plistDownload $1
