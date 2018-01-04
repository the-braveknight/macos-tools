#!/bin/bash

DIR=$(dirname $0)

function showOptions() {
    echo "-d,  Directory to install all kexts within."
    echo "-e,  Provide string (or plist-array file) of kext exceptions."
    echo "-h,  Show this help message."
    echo "Usage: $(basename $0) [Options] [Kext(s) to install]"
    echo "Example: $(basename $0) ~/Downloads/FakeSMC.kext"
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

while getopts e:d:h option; do
        case $option in
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
        esac
done

shift $((OPTIND-1))

if [[ $directory ]]; then
    kexts=$($DIR/find_kext.sh -d $directory -a)
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
    check $kext
    if [[ $? -eq 0 ]]; then installKext $kext; fi
done
