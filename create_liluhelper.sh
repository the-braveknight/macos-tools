#!/bin/bash

# Original idea from RehabMan

DIR=$(dirname ${BASH_SOURCE[0]})

source $DIR/_lilu_helper.sh

function showOptions() {
    echo "-o,  Output directory."
    echo "-h,  Show this help menu."
    echo "Usage: $(basename $0) [-o <output directory>]"
    echo "Example: $(basename $0) -o ~/Downloads"
}

while getopts o:h option; do
    case $option in
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

if [[ ! -d "$output_dir" ]]; then output_dir=.; fi

createLiluHelper "$output_dir"
