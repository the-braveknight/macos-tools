#!/bin/bash

if [[ ! -e $1 ]]; then
    echo "Usage: unarchive_file.sh {zip archive}"
    echo "Example: unarchive_file.sh ~/Downloads/MyArchive.zip"
    exit 1
fi

function unarchive() {
    filePath=${1/.zip/}
    rm -Rf $filePath
    unzip -q $1 -d $filePath
    rm -Rf $filePath/__MACOSX
}

for zip in $@; do
    unarchive $zip
done
