#!/bin/bash

# Original idea from RehabMan

DIR=$(dirname ${BASH_SOURCE[0]})

source $DIR/_lilu_helper.sh

function showOptions() {
    echo "-d,  Kexts directory (default: $kexts_directory)."
    echo "-o,  Output directory."
    echo "-h,  Show this help menu."
    echo "Usage: $(basename $0) [-o <output directory>]"
    echo "Example: $(basename $0) -o ~/Downloads"
}

while getopts d:o:h option; do
    case $option in
    d)
        kexts_directory=$OPTARG
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

createLiluHelper "$output_dir"
