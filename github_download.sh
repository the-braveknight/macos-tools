#!/bin/bash

function showOptions() {
    echo "-u,  GitHub user name."
    echo "-r,  GitHub repo name."
    echo "-f,  Partial file name to look for."
    echo "-o,  Output directory."
    echo "-h,  Show this help menu."
    echo "Usage: $(basename $0) [-u <GitHub user name>] [-r <GitHub repo name>] [-f <File name to look for>] [-o <Output directory>]"
    echo "Example: $(basename $0) -u vit9696 -r Lilu -f RELEASE -o ~/Downloads"
}

function download() {
# $1: GitHub user (author) name
# $2: GitHub repo name
# $3: Partial file name to look for ("RELEASE", "DEBUG", etc.)
# $4: Output directory
    curl --silent --location "https://github.com/$1/$2/releases" --output "/tmp/org.$1.download.txt"
    scrape=$(grep -o -m 1 "/.*$3.*\.zip" "/tmp/org.$1.download.txt")
    fileName="$1-$2.zip"
    echo Downloading $fileName
    curl --progress-bar --location https://github.com/$scrape --output $4/$fileName
}

if [[ ! -n $@ ]]; then showOptions; exit 1; fi

while getopts u:r:f:o:h option; do
    case $option in
    u)
        github_user=$OPTARG
    ;;
    r)
        github_repo=$OPTARG
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

if [[ ! -n $partial_name ]]; then partial_name=RELEASE; fi

if [[ ! -n $github_user || ! -n $github_repo ]]; then
    showOptions
    exit 1
fi

download $github_user $github_repo $partial_name $output_directory
