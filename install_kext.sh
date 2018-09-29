#!/bin/bash

DIR=$(dirname ${BASH_SOURCE[0]})

source $DIR/_install_cmds.sh

function showOptions() {
    echo "-d,  Directory to install all kexts within."
    echo "-s,  Destination directory (default: $kexts_dest)."
    echo "-e,  Exceptions list (single string) when installing multiple kexts."
    echo "-h,  Show this help message."
    echo "Usage: $(basename $0) [Options] [Kext to install]"
    echo "Example: $(basename $0) -e 'VoodooHDA|AppleALC|Sensors' ~/Downloads/*.kext"
}

while getopts e:s:d:h option; do
    case $option in
        e)
            exceptions=$OPTARG
        ;;
        s)
            kexts_dest=$OPTARG
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
    installKextsInDirectory "$directory" "$kexts_dest" "$exceptions"
elif [[ -d "$1" ]]; then
    installKext "$1"
else
    showOptions
    exit 1
fi
