#!/bin/bash

DIR=$(dirname ${BASH_SOURCE[0]})

source $DIR/_hda_cmds.sh

function showOptions() {
    echo "-c,  Codec name."
    echo "-r,  Codec resources folder."
    echo "-o,  Output directory."
    echo "Usage: $(basename $0) [-c <Codec name>] [-r <HDA resources folder>] [-o <Output directory>]"
    echo "Example: $(basename $0) -c ALC235 -r Resouces_ALC235"
}

while getopts c:r:o:h option; do
    case $option in
        c)
        codec=$OPTARG
        ;;
        r)
        resources=$OPTARG
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

if [[ -n "$codec" && -d "$resources" ]]; then
    createHDAInjector "$codec" "$resources" "$output_dir"
else
    showOptions
    exit 1
fi
