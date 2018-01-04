#!/bin/bash

function showOptions() {
    echo "-p,  Provide plist (array) of name/author pairs."
    echo "-a,  Provide name of author."
    echo "-n,  Provide name of repo (project)."
    echo "-o,  Provide output directory."
    echo "-h,  Show this help menu."
    echo "Usage: $(basename $0) [-a <author>] [-n <repo>] [-o <output directory>]"
    echo "Example: $(basename $0) -a RehabMan -n os-x-fakesmc-kozlek -o ~/Downloads"
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
# $1: Output directory
# $2: Plist file
    for ((index=0; 1; index++)); do
        author=$(/usr/libexec/PlistBuddy -c "Print ':$index:author'" $2 2>&1)
        name=$(/usr/libexec/PlistBuddy -c "Print ':$index:name'" $2 2>&1)
        if [[ "$author" == *"Does Not Exist"* ]]; then break; fi
        download $1 $author $name
    done
}

if [[ ! -n $@ ]]; then showOptions; exit 1; fi

while getopts a:n:p:o:h option; do
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
    o)
        outputDirectory=$OPTARG
    ;;
    h)
        showOptions
        exit 0
    ;;
    esac
done

shift $((OPTIND-1))

if [[ ! -e $outputDirectory ]]; then outputDirectory=.; fi

if [[ $plist ]]; then
    if [[ "$(plutil $plist)" != *"OK"* ]]; then
        echo "Error: Plist file corrupted or invalid."
        exit 1
    fi
    plistDownload $outputDirectory $plist
else
    if [[ ! -n $author || ! -n $name ]]; then
        showOptions
        exit 1
    fi
    download $outputDirectory $author $name
fi
