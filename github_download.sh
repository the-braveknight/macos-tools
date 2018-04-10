#!/bin/bash

curl_options="--retry 5 --location --progress-bar"
curl_options_silent="--retry 5 --location --silent"

function showOptions() {
    echo "-r,  GitHub repo for project."
    echo "-o,  Output file to save as."
    echo "-h,  Show this help menu."
    echo "Usage: $(basename $0) [-r <GitHub repo release page URL>] [-o <output filename>]"
#    echo "Example: $(basename $0) -a RehabMan -n os-x-fakesmc-kozlek -o ~/Downloads"
}

# download latest release from github (perhaps others)
# by RehabMan
function download_latest()
# $1 is main URL
# $2 is URL of release page
# $3 is partial file name to look for
# $4 is file name to rename to
{
    echo "downloading latest $4 from $2:"
    curl $curl_options_silent --output /tmp/org.rehabman.download.txt "$2"
    local scrape=`grep -o -m 1 "/.*$3.*\.zip" /tmp/org.rehabman.download.txt`
    local url=$1$scrape
    echo $url
    curl $curl_options --output "$4" "$url"
    echo
}

if [[ ! -n $@ ]]; then showOptions; exit 1; fi

while getopts r:n:o:h option; do
    case $option in
    r)
        release_url=$OPTARG
    ;;
    n)
        name=$OPTARG
    ;;
    o)
        output_filename=$OPTARG
    ;;
    h)
        showOptions
        exit 0
    ;;
    esac
done

shift $((OPTIND-1))

if [[ ! -e $outputDirectory ]]; then outputDirectory=.; fi

if [[ ! -n $release_url || ! -n $output_filename ]]; then
    showOptions
    exit 1
fi

download_latest "https://github.com" $release_url "RELEASE" $output_filename
