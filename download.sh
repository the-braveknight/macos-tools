#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

settings=$1

if [[ ! -e $settings ]]; then
    echo "Usage: download.sh {settings.plist file}"
    echo "Example: download.sh ~/Desktop/settings.plist"
    echo "Refer to settings-sample.plist for example"
    exit 1
fi

function download() {
    curl --silent --output /tmp/org.$1.download.txt --location https://bitbucket.org/$1/$2/downloads/
    scrape=$(grep -o -m 1 "$1/$2/downloads/$3.*\.zip" /tmp/org.$1.download.txt | sed 's/".*//')
    echo Downloading $(basename $scrape)
    curl --remote-name --progress-bar --location https://bitbucket.org/$scrape
}

os_version=$($DIR/os_version.sh)

function downloadCategory() {
    if [[ ! -d $DIR/downloads/$1 ]]; then
        mkdir $DIR/downloads/$1
    fi

    for ((file=0; 1; file++)); do
        author=$(/usr/libexec/PlistBuddy -c "Print ':Downloads:$1:$file:author'" $settings 2>&1)
        name=$(/usr/libexec/PlistBuddy -c "Print ':Downloads:$1:$file:name'" $settings 2>&1)

        if [[ "$author" == *"Does Not Exist"* ]]; then
            break
        fi

        minimum_os=$(/usr/libexec/PlistBuddy -c "Print ':Downloads:$1:$file:Minimum OS'" $settings 2>&1)
        if [[ "$minimum_os" != *"Does Not Exist"* && $os_version -lt $minimum_os ]]; then
            continue
        fi

        maximum_os=$(/usr/libexec/PlistBuddy -c "Print ':Downloads:$1:$file:Maximum OS'" $settings 2>&1)
        if [[ "$maximum_os" != *"Does Not Exist"* && $os_version -gt $maximum_os ]]; then
            continue
        fi

        cd $DIR/downloads/$1
        download $author $name
        cd $DIR
    done
}

rm -Rf $DIR/downloads && mkdir $DIR/downloads

# Download kexts
downloadCategory "kexts"

# Download tools
downloadCategory "tools"
