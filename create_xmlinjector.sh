#!/bin/bash

DIR=$(dirname $0)

hda_native=/System/Library/Extensions/AppleHDA.kext

function showOptions() {
    echo "-c,  Codec name."
    echo "-r,  Codec resources folder."
    echo "-o,  Output directory."
    echo "Usage: $(basename $0) [-r <HDA resources folder>] [-c <Codec name>] [-o <Output directory>]"
    echo "Example: $(basename $0) -r Resouces_CX20751 -c CX20751"
}

function createLayoutsInjector() {
# $1: Codec name
# $2: Resources folder
# $3: Output directory
    hda_injector=$3/AppleHDA_$1.kext

    echo "Creating $(basename $hda_injector)"

    rm -Rf $hda_injector && mkdir -p $hda_injector/Contents/Resources && mkdir -p $hda_injector/Contents/MacOS
    ln -s $hda_native/Contents/MacOS/AppleHDA $hda_injector/Contents/MacOS/AppleHDA

    cp $hda_native/Contents/Info.plist $hda_injector/Contents/Info.plist

    $DIR/fix_info_versions.sh $hda_injector/Contents/Info.plist

    for layout in $2/layout*.plist; do
        $DIR/tools/zlib deflate $layout > $hda_injector/Contents/Resources/$(basename $layout .plist).xml.zlib
    done

    $DIR/tools/zlib inflate $hda_native/Contents/Resources/Platforms.xml.zlib > /tmp/Platforms.plist
    /usr/libexec/PlistBuddy -c "Delete ':PathMaps'" /tmp/Platforms.plist
    /usr/libexec/PlistBuddy -c "Merge $2/Platforms.plist" /tmp/Platforms.plist
    $DIR/tools/zlib deflate /tmp/Platforms.plist > $hda_injector/Contents/Resources/Platforms.xml.zlib
}

while getopts o:c:r:h option; do
    case $option in
        o)
            directory=$OPTARG
        ;;
        c)
            codec=$OPTARG
        ;;
        r)
            resources=$OPTARG
        ;;
        h)
            showOptions
            exit 0
        ;;
    esac
done

if [[ ! -d $directory ]]; then directory=.; fi

if [[ ! -d $resources || ! -n $codec ]]; then
    showOptions
    exit 1
fi

createLayoutsInjector $codec $resources $directory
