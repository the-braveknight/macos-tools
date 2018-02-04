#!/bin/bash

DIR=$(dirname $0)

kexts_dir=/Library/Extensions

function showOptions() {
    echo "-d,  Directory to install all kexts within."
    echo "-i,  Install kext(s) to EFI/CLOVER/kexts/Other."
    echo "-e,  Kexts exceptions (single string) when installing multiple kexts."
    echo "-h,  Show this help message."
    echo "Usage: $(basename $0) [-e <Kext exceptions>] [Kext(s) to install]"
    echo "Example: $(basename $0) -e 'VoodooHDA|AppleALC|Sensors' ~/Downloads/*.kext"
}

function installKext() {
    kextName=$(basename $1)
    echo Installing $kextName to $kexts_dir
    sudo rm -Rf $kexts_dir/$kextName
    sudo cp -Rf $1 $kexts_dir
}

function check() {
    kextName=$(basename $1)
    if [[ -z $exceptions || $(echo $1 | grep -vE "$exceptions") ]]; then echo 1; fi
}

while getopts e:id:h option; do
        case $option in
            e)
                exceptions=$OPTARG
            ;;
            i)
                EFI=$($DIR/mount_efi.sh)
                kexts_dir=$EFI/EFI/CLOVER/kexts/Other
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
