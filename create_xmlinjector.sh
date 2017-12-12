#!/bin/bash

hda_native=/System/Library/Extensions/AppleHDA.kext

function createLayoutsInjector() {
    hda_injector=AppleHDA_$1.kext

    echo "Creating $hda_injector"

    rm -Rf $hda_injector && mkdir -p $hda_injector/Contents/Resources && mkdir -p $hda_injector/Contents/MacOS
    ln -s $hda_native/Contents/MacOS/AppleHDA $hda_injector/Contents/MacOS/AppleHDA

    cp $hda_native/Contents/Info.plist $hda_injector/Contents/Info.plist

    ./fix_info_versions.sh $hda_injector/Contents/Info.plist

    for layout in Resources_$1/layout*.plist; do
        ./tools/zlib deflate $layout > $hda_injector/Contents/Resources/$(basename $layout .plist).xml.zlib
    done

    ./tools/zlib inflate $hda_native/Contents/Resources/Platforms.xml.zlib > /tmp/Platforms.plist
    /usr/libexec/PlistBuddy -c "Delete ':PathMaps'" /tmp/Platforms.plist
    /usr/libexec/PlistBuddy -c "Merge Resources_$1/Platforms.plist" /tmp/Platforms.plist
    ./tools/zlib deflate /tmp/Platforms.plist > $hda_injector/Contents/Resources/Platforms.xml.zlib
}

./check_directory.sh Resources_$1
if [ $? -ne 0 ]; then
    echo Usage: create_xmlinjector.sh {codec}
    echo Example: create_xmlinjector.sh CX20751
    exit 1
fi

createLayoutsInjector "$1"
