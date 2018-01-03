#!/bin/bash

function showOptions() {
    echo "-n,  Name of kext to search for."
    echo "-d,  Directory to search in."
    echo "-a,  Find all kexts within current directory (or the directory chosen with -d)."
    echo "-h,  Show this help message."
}

function inputError() {
    echo "Usage: find_kext.sh -n {name} -d {directory}"
    echo "Example: find_kext.sh -n FakeSMC.kext -d ~/Downloads/Kexts"
}

function findKext() {
# $1: Directory
# $2: Kext name
    find $1 -path \*/$2 -not -path \*/PlugIns/* -not -path \*/Debug/*
}

while getopts n:d:ah option; do
    case $option in
        n)
            name=$OPTARG
        ;;
        d)
            directory=$OPTARG
        ;;
        a)
            name=*.kext
        ;;
        h)
            showOptions
            exit 0
        ;;
        \?)
            showOptions
            exit 1
        ;;
    esac
done

if [[ -d $directory ]]; then
    findKext $directory "$name"
else
    findKext . "$name"
fi
