#!/bin/bash

DIR=$(dirname $0)

function kextError() {
    echo "Error: Cannot find $1. Please make sure you enter the correct path."
}

function showOptions() {
    echo "-n,  Provide path of kext(s) to install."
    echo "-a,  Install all kexts within current directory (or the directory chosen with -d)."
    echo "-e,  Provide string (or plist-array file) of kext exceptions."
    echo "-d,  Provide directory."
    echo "-h,  Show this help message."
}

function installKext() {
    kextName=$(basename $1)
    echo Installing $kextName to /Library/Extensions
    sudo rm -Rf /Library/Extensions/$kextName
    sudo cp -Rf $1 /Library/Extensions
}

function check() {
    kextName=$(basename $1)
    for exception in $exceptions; do
        if [[ "$kextName" == *"$exception"* ]]; then return 1; fi
    done
    return 0
}

if [[ ! -n $@ ]]; then showOptions; exit 1; fi

while getopts n:ae:d:h option; do
        case $option in
            n)
                named=$OPTARG
            ;;
            a)
                all=true
            ;;
            e)
                if [[ $(plutil $OPTARG) == *"OK"* ]]; then
                    exceptions=$(grep -o '<string>.*</string>' $OPTARG | sed -e 's/<[^>]*>//g')
                else
                    exceptions=$OPTARG
                fi
            ;;
            d)
                directory=$OPTARG
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

if [[ ! -n $directory ]]; then directory=.; fi

if [[ -n $all ]]; then
    kexts=$($DIR/find_kext.sh -a -d $directory)
else
    if [[ ! -n $named ]]; then showOptions; exit 1; fi
    kexts=$named
fi

for kext in $kexts; do
    if [[ ! -d $kext ]]; then kextError $kext; exit 1; fi
    check $kext
    if [[ $? -eq 0 ]]; then installKext $kext; fi
done
