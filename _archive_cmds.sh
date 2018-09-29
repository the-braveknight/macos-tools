#!/bin/bash

function findArchive() {
# $1: Zip
# $2: Directory
    find "$2" -name "$1"
}

function unarchive() {
# $1: Zip file
    filePath=${1/.zip/}
    rm -Rf $filePath
    unzip -q $1 -d $filePath
    rm -Rf $filePath/__MACOSX
}

function unarchiveAllInDirectory() {
# $1: Directory
    for zip in $(findArchive "*.zip" "$1"); do
        unarchive "$zip"
    done
}
