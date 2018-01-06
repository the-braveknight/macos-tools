#!/bin/bash

function showOptions() {
    echo "-d,  Directory to install all kexts within."
    echo "-e,  Kexts exceptions (single string) when installing multiple kexts."
    echo "-h,  Show this help message."
    echo "Usage: $(basename $0) [-e <Kext exceptions>] [Kext(s) to install]"
    echo "Example: $(basename $0) -e 'VoodooHDA|AppleALC|Sensors' ~/Downloads/*.kext"
}

function installKext() {
    kextName=$(basename $1)
    echo Installing $kextName to /Library/Extensions
    sudo rm -Rf /Library/Extensions/$kextName
    sudo cp -Rf $1 /Library/Extensions
}



function check() {
    kextName=$(basename $1)
    if [[ -z $exceptions || $(echo $1 | grep -vE $exceptions) ]]; then echo 1; fi
}

while getopts e:d:h option; do
        case $option in
            e)
                exceptions=$OPTARG
            ;;
            d)
                directory=$OPTARG
            ;;
            h)
                showOptions
                exit 0
            ;;
        esac
done

shift $((OPTIND-1))

if [[ $directory ]]; then
    kexts=$(find $directory -path \*.kext -not -path \*/PlugIns/* -not -path \*/Debug/*)
elif [[ $@ ]]; then
    kexts=$@
else
    showOptions
    exit 1
fi

for kext in $kexts; do
    if [[ ! -d $kext ]]; then
        echo "Could not find $kext. Make sure the path is correct."
        continue
    fi
    if [[ $(check $kext) ]]; then installKext $kext; fi
done
