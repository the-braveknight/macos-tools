#!/bin/bash

DIR=$(dirname ${BASH_SOURCE[0]})

source $DIR/_download_cmds.sh

function showOptions() {
    echo "-a,  GitHub username (author)."
    echo "-r,  Repo (project) name."
    echo "-f,  Partial file name to look for."
    echo "-o,  Output directory (default: $output_dir)."
    echo "-h,  Show this help menu."
    echo "Usage: $(basename $0) [-a <author>] [-r <repo>] [-f <File name to look for>] [-o <output directory>]"
    echo "Example: $(basename $0) -a Acidanthera -r Lilu -o ~/Downloads"
}

while getopts a:r:f:o:h option; do
    case $option in
    a)
        author=$OPTARG
    ;;
    r)
        repo=$OPTARG
    ;;
    f)
        partial_name=$OPTARG
    ;;
    o)
        output_dir=$OPTARG
    ;;
    h)
        showOptions
        exit 0
    ;;
    esac
done

shift $((OPTIND-1))

if [[ -n "$author" && -n "$repo" ]]; then
    githubDownload "$author" "$repo" "$output_dir" "$partial_name"
else
    showOptions
    exit 1
fi
