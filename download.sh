#!/bin/bash

DIR="$( cd "$(dirname "$0")" ; pwd -P )"

settings=$(find $PWD -name $1)

os_version=$($DIR/os_version.sh)

function bitbucketDownload() {
    rm -Rf Downloads/$1 && mkdir -p Downloads/$1 && cd Downloads/$1
    for ((index=0; 1; index++)); do
        author=$(/usr/libexec/PlistBuddy -c "Print ':Downloads:$1:$index:author'" $settings 2>&1)
        name=$(/usr/libexec/PlistBuddy -c "Print ':Downloads:$1:$index:name'" $settings 2>&1)

        if [[ "$author" == *"Does Not Exist"* ]]; then
            break
        fi

        minimum_os=$(/usr/libexec/PlistBuddy -c "Print ':Downloads:$1:$index:Minimum OS'" $settings 2>&1)
        if [[ "$minimum_os" != *"Does Not Exist"* && $os_version -lt $minimum_os ]]; then
            continue
        fi

        maximum_os=$(/usr/libexec/PlistBuddy -c "Print ':Downloads:$1:$index:Maximum OS'" $settings 2>&1)
        if [[ "$maximum_os" != *"Does Not Exist"* && $os_version -gt $maximum_os ]]; then
            continue
        fi

        $DIR/bitbucket_download.sh $author $name
    done
    cd ../..
}

function downloadACPI() {
    rm -Rf Downloads/Hotpatch && mkdir -p Downloads/Hotpatch && cd Downloads/Hotpatch
    for ((index=0; 1; index++)); do
        SSDT=$(/usr/libexec/PlistBuddy -c "Print ':Hotpatch:$index'" $settings 2>&1)

        if [[ "$SSDT" == *"Does Not Exist"* ]]; then
            break
        fi

        $DIR/download_ssdt.sh $SSDT
    done
    cd ../..
}

if [[ ! -e $settings ]]; then
    echo "Usage: download.sh {settings.plist file}"
    echo "Example: download.sh ~/Desktop/settings.plist"
    echo "Refer to settings-sample.plist for example"
    exit 1
fi

# Download Kexts
bitbucketDownload "Kexts"

# Download Tools
bitbucketDownload "Tools"

downloadACPI
