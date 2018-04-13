#!/bin/bash

function showOptions() {
    echo "-a,  Name of author."
    echo "-n,  Name of repo (project)."
    echo "-f,  Partial file name to look for."
    echo "-o,  Output directory."
    echo "-h,  Show this help menu."
    echo "Usage: $(basename $0) [-a <author>] [-n <repo>] [-f <File name to look for>] [-o <output directory>]"
    echo "Example: $(basename $0) -a RehabMan -n os-x-fakesmc-kozlek -o ~/Downloads"
}

function download() {
# $1: Output directory
# $2: Author
# $3: Project (repo)
# $4: Partial file name to look for
    curl --silent --output /tmp/org.$2.download.txt --location https://bitbucket.org/$2/$3/downloads/
    scrape=$(grep -o -m 1 "$2/$3/downloads/$4.*\.zip" /tmp/org.$2.download.txt | sed 's/".*//')
    fileName=$(basename $scrape)
    echo Downloading $fileName
    curl --progress-bar --location https://bitbucket.org/$scrape --output $1/$fileName
}

if [[ ! -n $@ ]]; then showOptions; exit 1; fi

while getopts a:n:f:o:h option; do
    case $option in
    a)
        author=$OPTARG
    ;;
    n)
        name=$OPTARG
    ;;
    f)
        partial_name=$OPTARG
    ;;
    o)
        output_directory=$OPTARG
    ;;
    h)
        showOptions
        exit 0
    ;;
    esac
done

shift $((OPTIND-1))

if [[ ! -e $output_directory ]]; then output_directory=.; fi

if [[ ! -n $author || ! -n $name ]]; then
    showOptions
    exit 1
fi

download $output_directory $author $name $partial_name
