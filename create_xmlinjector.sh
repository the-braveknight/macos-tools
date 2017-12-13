#!/bin/bash

DIR=$(dirname $0)

resources=$1

hda_native=/System/Library/Extensions/AppleHDA.kext

function createLayoutsInjector() {
    hda_injector=AppleHDAInjector.kext

    echo "Creating $hda_injector"

    rm -Rf $hda_injector && mkdir -p $hda_injector/Contents/Resources && mkdir -p $hda_injector/Contents/MacOS
    ln -s $hda_native/Contents/MacOS/AppleHDA $hda_injector/Contents/MacOS/AppleHDA

    cp $hda_native/Contents/Info.plist $hda_injector/Contents/Info.plist

    $DIR/fix_info_versions.sh $hda_injector/Contents/Info.plist

    for layout in $resources/layout*.plist; do
        $DIR/tools/zlib deflate $layout > $hda_injector/Contents/Resources/$(basename $layout .plist).xml.zlib
    done

    $DIR/tools/zlib inflate $hda_native/Contents/Resources/Platforms.xml.zlib > /tmp/Platforms.plist
    /usr/libexec/PlistBuddy -c "Delete ':PathMaps'" /tmp/Platforms.plist
    /usr/libexec/PlistBuddy -c "Merge $resources/Platforms.plist" /tmp/Platforms.plist
    $DIR/tools/zlib deflate /tmp/Platforms.plist > $hda_injector/Contents/Resources/Platforms.xml.zlib
}

if [[ ! -d $resources ]]; then
    echo "Usage: create_xmlinjector.sh {HDA resources folder}"
    echo "Example: create_xmlinjector.sh Resouces_CX20751"
    exit 1
fi

createLayoutsInjector
