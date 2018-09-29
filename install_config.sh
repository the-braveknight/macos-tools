#!/bin/bash

DIR=$(dirname ${BASH_SOURCE[0]})

source $DIR/_config_cmds.sh

function showOptions() {
    echo "-u,  Update only relevant settings (Preserve user settings like SMBIOS, etc)."
    echo "-h,  Show this help message."
    echo "Usage: $(basename $0) [Options] [New config.plist]"
    echo "Example: $(basename $0) -u ~/Downloads/config.plist"
}

while getopts uh option; do
    case $option in
        u)
            update=1
        ;;
        h)
            showOptions
            exit 0
        ;;
    esac
done

shift $((OPTIND-1))

if [[ -e "$1" ]]; then
    if [[ -n "$update" ]]; then
        updateConfig "$1"
    else
        installConfig "$1"
    fi
else
    showOptions
    exit 1
fi
