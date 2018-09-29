#!/bin/bash

output_dir=~/Downloads

hotpatch_repo="https://github.com/RehabMan/OS-X-Clover-Laptop-Config/raw/master/hotpatch"

function downloadSSDT() {
# $1: SSDT name
# $2: Output directory (optional)
    if [[ -d "$2" ]]; then
        local output_dir="$2"
    fi
    echo "Downloading $1 to $output_dir"
    url="$hotpatch_repo/$1"
    curl --progress-bar --location "$url" --output "$output_dir/$1"
}

function bitbucketDownload() {
# $1: Author
# $2: Repo
# $3: Output directory (optional)
# $4: Partial file name to look for (optional)
    if [[ -d "$3" ]]; then
        local output_dir="$3"
        if [[ -n "$4" ]]; then
            local partial_name="$4"
        fi
    elif [[ -n "$3" ]]; then
        local partial_name="$3"
    fi
    curl --silent --output /tmp/org.$1.download.txt --location https://bitbucket.org/$1/$2/downloads/
    scrape=$(grep -o -m 1 "$1/$2/downloads/$partial_name.*\.zip" /tmp/org.$1.download.txt | sed 's/".*//')
    fileName=$(basename $scrape)
    echo Downloading $fileName to $output_dir
    curl --progress-bar --location https://bitbucket.org/$scrape --output $output_dir/$fileName
}

function githubDownload() {
# $1: Author
# $2: Repo
# $3: Output directory (optional)
# $4: Partial file name to look for (optional)
    if [[ -d "$3" ]]; then
        local output_dir="$3"
        if [[ -n "$4" ]]; then
            local partial_name="$4"
        fi
    elif [[ -n "$3" ]]; then
        local partial_name="$3"
    fi
    curl --silent --location "https://github.com/$1/$2/releases" --output "/tmp/org.$1.download.txt"
    filename_matched=$(grep -o -m 1 "/.*$partial_name.*\.zip" "/tmp/org.$1.download.txt")
    release=$(grep -o -m 1 "/.RELEASE.*\.zip" "/tmp/org.$1.download.txt")
    debug=$(grep -o -m 1 "/.*DEBUG.*\.zip" "/tmp/org.$1.download.txt")
    if [[ -n "$filename_matched" ]]; then
        scrape=$filename_matched
    elif [[ -n "$release" ]]; then
        scrape=$release
    elif [[ -n "$debug" ]]; then
        scrape=$debug
    fi
    fileName="$1-$2.zip"
    echo Downloading $fileName to $output_dir
    curl --progress-bar --location https://github.com/$scrape --output $output_dir/$fileName
}
