#!/bin/bash

DIR=$(dirname ${BASH_SOURCE[0]})

source $DIR/_download_cmds.sh

function showOptions() {
    echo "-a,  Download all SSDTs within RehabMan's repo."
    echo "-o,  Output directory."
    echo "-h,  Show this help message."
    echo "Usage: $(basename $0) [Options] [SSDT to download]"
    echo "Example: $(basename $0) -o ~/Desktop SSDT-PNLF.dsl"
}

while getopts ao:h option; do
    case $option in
        a)
            all=1
        ;;
        o)
            output_dir=$OPTARG
        ;;
        h)
            showOptions
            exit 0
        ;;
    esac
done

shift $((OPTIND-1))

if [[ "$all" ]]; then
    downloadAllHotpatchSSDTs "$output_dir"
else
    if [[ -n "$1" ]]; then
        downloadSSDT "$1" "$output_dir"
    else
        showOptions
        exit 1
    fi
fi
