#!/bin/bash

DIR=$(dirname ${BASH_SOURCE[0]})

source $DIR/_install_cmds.sh

function showOptions() {
    echo "-d,  Directory to install all tools within."
    echo "-s,  Destination directory (default: $tools_dest)."
    echo "-e,  Exceptions list (single string) when installing multiple tools."
    echo "-h,  Show this help message."
    echo "Usage: $(basename $0) [Options] [Tool to install]"
    echo "Example: $(basename $0) ~/Downloads/mount_efi.sh"
}

while getopts e:s:d:h option; do
    case $option in
        e)
            exceptions=$OPTARG
        ;;
        s)
            tools_dest=$OPTARG
        ;;
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
    installToolsInDirectory "$directory" "$tools_dest" "$exceptions"
elif [[ -e "$1" ]]; then
    installTool "$1"
else
    showOptions
    exit 1
fi
