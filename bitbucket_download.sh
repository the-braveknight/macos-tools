#!/bin/bash

DIR=$(dirname $0)

function download() {
    curl --silent --output /tmp/org.$1.download.txt --location https://bitbucket.org/$1/$2/downloads/
    scrape=$(grep -o -m 1 "$1/$2/downloads/$3.*\.zip" /tmp/org.$1.download.txt | sed 's/".*//')
    echo Downloading $(basename $scrape)
    curl --remote-name --progress-bar --location https://bitbucket.org/$scrape
}

if [[ "$1" == "" ]]; then
    echo "Usage: bitbucket_download.sh {bitbucket repo} {project} {(Optional) filename}"
    echo "Example: bitbucket_download.sh RehabMan os-x-fakesmc-kozlek"
    exit 1
fi

download $@
