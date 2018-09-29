#!/bin/bash

DIR=$(dirname ${BASH_SOURCE[0]})

source $DIR/_archive_cmds.sh

function showOptions() {
    echo "-d,  Directory to unarchive all archives within."
    echo "-h,  Show this help message."
    echo "Usage: $(basename $0) [Options] [Archive to unarchive]"
    echo "Example: $(basename $0) ~/Downloads/Files.zip"
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

shift $((OPTIND-1))

if [[ -d "$directory" ]]; then
    unarchiveAllInDirectory "$directory"
elif [[ -e "$1" ]]; then
    unarchive "$1"
else
    showOptions
    exit 1
fi
