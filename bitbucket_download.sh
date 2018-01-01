#!/bin/bash

function download() {
# $1: Output directory
# $2: Author
# $3: Project (repo)
# $4: (Optional) Extra file name matching
    curl --silent --output /tmp/org.$2.download.txt --location https://bitbucket.org/$2/$3/downloads/
    scrape=$(grep -o -m 1 "$2/$3/downloads/$4.*\.zip" /tmp/org.$2.download.txt | sed 's/".*//')
    fileName=$(basename $scrape)
    echo Downloading $fileName
    curl --progress-bar --location https://bitbucket.org/$scrape --output $1/$fileName
}

function plistDownload() {
    directory=Downloads/$(basename $1 .plist)
    if [[ ! -d $directory ]]; then mkdir -p $directory; fi
    for ((index=0; 1; index++)); do
        author=$(/usr/libexec/PlistBuddy -c "Print ':$index:author'" $1 2>&1)
        name=$(/usr/libexec/PlistBuddy -c "Print ':$index:name'" $1 2>&1)
        if [[ "$author" == *"Does Not Exist"* ]]; then break; fi
        download $directory $author $name
    done
}

if [[ ! -e $1 ]]; then
    echo "Usage: bitbucket_download.sh {plist file}"
    echo "Example: bitbucket_download.sh ~/Desktop/Tools.plist"
    exit 1
elif [[ $(plutil $1) != *"OK"* ]]; then
    echo "Error: Plist file corrupt or invalid."
    exit 1
fi

plistDownload $1
