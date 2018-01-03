#!/bin/bash

function showOptions() {
    echo "-p,  Provide plist (array) with name/author pairs."
    echo "-a,  Provide name of author."
    echo "-n,  Provide name of repo (project)."
    echo "-h,  Show this help menu."
}

function plistError() {
    echo "Error: Plist file corrupted or invalid."
}

function inputError() {
    echo "Usage: bitbucket_download.sh -n {name} -a {author}"
    echo "Example: bitbucket_download.sh -a RehabMan -n os-x-fakesmc-kozlek"
}

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

if [[ ! -n $@ ]]; then showOptions; exit 1; fi

while getopts a:n:p:h option; do
    case $option in
    a)
        author=$OPTARG
    ;;
    n)
        name=$OPTARG
    ;;
    p)
        plist=$OPTARG
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

if [[ -n $plist ]]; then
    if [[ "$(plutil $plist)" != *"OK"* ]]; then plistError; exit 1; fi
    plistDownload $plist
else
    if [[ ! -n $author || ! -n $name ]]; then inputError; exit 1; fi
    download . $author $name
fi
