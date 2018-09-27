#!/bin/bash

directory=/Library/Extensions

function showOptions() {
    echo "-d,  Kexts directory (default: /Library/Extensions)."
    echo "-h,  Show this help message."
    echo "Usage: $(basename $0) [-d <Kexts directory>]"
    echo "Example: $(basename $0) -d /Library/Extensions"
}

while getopts d:h option; do
    case $option in
        d)
            directory=$OPTARG
        ;;
        h)
            showOptions
            exit 0
        ;;
    esac
done

if [[ ! -d $directory ]]; then showOptions; exit 1; fi

for kext in $directory/*.kext; do
    if [[ ! -d $kext/Contents/_CodeSignature && ! -d $kext/_CodeSignature ]]; then
        echo $kext
    fi
done
