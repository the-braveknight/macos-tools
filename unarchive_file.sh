#!/bin/bash

function showOptions() {
    echo "-d,  Directory to unzip all archives within."
    echo "-h,  Show this help message."
    echo "Usage: $(basename $0) [Options] [Archives to unzip]"
    echo "Example: $(basename $0) ~/Downloads/Files.zip ~/Downloads/Documents.zip"
}

function unarchive() {
    filePath=${1/.zip/}
    rm -Rf $filePath
    unzip -q $1 -d $filePath
    rm -Rf $filePath/__MACOSX
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

if [[ $directory ]]; then
    zips=$(find $directory -name "*.zip")
elif [[ $@ ]]; then
    zips=$@
else
    showOptions
    exit 1
fi

for zip in $zips; do
    if [[ ! -e $zip ]]; then
        echo "Could not find $zip. Make sure the path is correct."
        continue
    fi
    unarchive $zip
done
