#!/bin/bash

DIR=$(dirname ${BASH_SOURCE[0]})

source $DIR/_plist_utils.sh

output_dir=.

native_hda=/System/Library/Extensions/AppleHDA.kext
native_hcd=$native_hda/Contents/PlugIns/AppleHDAHardwareConfigDriver.kext

function fixVersion() {
# $1: Version property key
# $2: Plist file
    oldValue=$(printValue "$1" $2)
    newValue=$(echo $oldValue | perl -p -e 's/(\d*\.\d*(\.\d*)?)/9\1/')
    setValue "$1" "$newValue" $2
}

function createHDAInjector() {
# $1: Codec name
# $2: Resources folder
# $3: Output directory
    if [[ -d "$3" ]]; then
        local output_dir="$3"
    fi
    hda_injector=$output_dir/AppleHDA_$1.kext
    rm -Rf $hda_injector && mkdir -p $hda_injector/Contents/Resources && mkdir -p $hda_injector/Contents/MacOS
    ln -s $native_hda/Contents/MacOS/AppleHDA $hda_injector/Contents/MacOS/AppleHDA
    cp $native_hda/Contents/Info.plist $hda_injector/Contents/Info.plist

    fixVersion ":NSHumanReadableCopyright" $hda_injector/Contents/Info.plist
    fixVersion ":CFBundleVersion" $hda_injector/Contents/Info.plist
    fixVersion ":CFBundleGetInfoString" $hda_injector/Contents/Info.plist
    fixVersion ":CFBundleShortVersionString" $hda_injector/Contents/Info.plist

    for layout in $2/layout*.plist; do
        $DIR/zlib deflate $layout > $hda_injector/Contents/Resources/$(basename $layout .plist).xml.zlib
    done

    $DIR/zlib inflate $native_hda/Contents/Resources/Platforms.xml.zlib > /tmp/Platforms.plist
    delete "PathMaps" /tmp/Platforms.plist
    mergePlist "$2/Platforms.plist" ":" /tmp/Platforms.plist
    $DIR/zlib deflate /tmp/Platforms.plist > $hda_injector/Contents/Resources/Platforms.xml.zlib

    addDictionary "HardwareConfigDriver_Temp" $hda_injector/Contents/Info.plist
    mergePlist "$native_hcd/Contents/Info.plist" "HardwareConfigDriver_Temp" $hda_injector/Contents/Info.plist
    copy ":HardwareConfigDriver_Temp:IOKitPersonalities:HDA Hardware Config Resource" ":IOKitPersonalities:HDA Hardware Config Resource" $hda_injector/Contents/Info.plist
    delete "HardwareConfigDriver_Temp" $hda_injector/Contents/Info.plist
    delete "IOKitPersonalities:HDA Hardware Config Resource:HDAConfigDefault" $hda_injector/Contents/Info.plist
    delete "IOKitPersonalities:HDA Hardware Config Resource:PostConstructionInitialization" $hda_injector/Contents/Info.plist
    addInteger "IOKitPersonalities:HDA Hardware Config Resource:IOProbeScore" 2000 $hda_injector/Contents/Info.plist
    mergePlist "$2/ahhcd.plist" "IOKitPersonalities:HDA Hardware Config Resource" $hda_injector/Contents/Info.plist
}
