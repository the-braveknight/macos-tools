#!/bin/bash

function showOptions() {
    echo "-d,  Directory to search in (Default is current directory)."
    echo "-a,  Find all kexts within current directory (works with -d)."
    echo "-h,  Show this help message."
    echo "Usage: $(basename $0) [Options] [Kext(s) to find]"
    echo "Example: $(basename $0) -d ~/Downloads FakeSMC.kext"
}

function findKext() {
# $1: Directory
# $2: Kext name
    find $1 -path \*/$2 -not -path \*/PlugIns/* -not -path \*/Debug/*
}

while getopts d:ah option; do
    case $option in
        d)
            directory=$OPTARG
        ;;
        a)
            all=*.kext
        ;;
        h)
            showOptions
            exit 0
        ;;
    esac
done

shift $((OPTIND-1))

if [[ ! -d $directory ]]; then directory=.; fi

if [[ $all ]]; then
    kexts=$all
elif [[ $@ ]]; then
    kexts=$@
else
    showOptions
    exit 1
fi

for kext in "$kexts"; do
    findKext $directory "$kext"
done
