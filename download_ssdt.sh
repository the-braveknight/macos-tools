#!/bin/bash

acpi_repo=https://github.com/RehabMan/OS-X-Clover-Laptop-Config/raw/master/hotpatch

function downloadACPI() {
    echo "Downloading $1..."
    url=$acpi_repo/$1
    curl --remote-name --progress-bar --location $url
}

if [[ "$1" == "" ]]; then
    echo "Usage: download_acpi.sh {SSDT name from RehabMan's Repo}"
    echo "Example: download_acpi.sh SSDT-IGPU.dsl"
    exit 1
fi

for file in $@; do
    downloadACPI $file
done
