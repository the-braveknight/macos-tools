#!/bin/bash

acpi_repo=https://github.com/RehabMan/OS-X-Clover-Laptop-Config/raw/master/hotpatch

function showOptions() {
    echo "-o,  Output directory."
    echo "-h,  Show this help message."
    echo "Usage: $(basename $0) [-o <output directory>] [SSDTs to download]"
    echo "Example: $(basename $0) -o ~/Downloads SSDT-IGPU.dsl SSDT-PNLF.dsl"
}

function download() {
# $1: Output directory
# $2: Hotpatch SSDT name
    echo "Downloading $2..."
    url=$acpi_repo/$2
    curl --progress-bar --location $url --output $1/$2
}

while getopts o:h option; do
    case $option in
        o)
            output_directory=$OPTARG
        ;;
        h)
            showOptions
            exit 0
        ;;
    esac
done

shift $((OPTIND-1))

if [[ ! -d $output_directory ]]; then output_directory=.; fi

if [[ $@ ]]; then
    ssdts=$@
else
    showOptions
    exit 1
fi

for ssdt in $ssdts; do
    download $output_directory $ssdt
done
