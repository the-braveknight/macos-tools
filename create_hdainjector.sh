#!/bin/bash

DIR=$(dirname $0)

resources=$1

hda_native=/System/Library/Extensions/AppleHDA.kext
hcd_native=$hda_native/Contents/PlugIns/AppleHDAHardwareConfigDriver.kext

function createHDAInjector() {
    hda_injector=AppleHDAInjector.kext

    $DIR/create_xmlinjector.sh $resources

    /usr/libexec/PlistBuddy -c "Add ':HardwareConfigDriver_Temp' dict" $hda_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Merge $hcd_native/Contents/Info.plist ':HardwareConfigDriver_Temp'" $hda_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Copy ':HardwareConfigDriver_Temp:IOKitPersonalities:HDA Hardware Config Resource' ':IOKitPersonalities:HDA Hardware Config Resource'" $hda_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Delete ':HardwareConfigDriver_Temp'" $hda_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Delete ':IOKitPersonalities:HDA Hardware Config Resource:HDAConfigDefault'" $hda_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Delete ':IOKitPersonalities:HDA Hardware Config Resource:PostConstructionInitialization'" $hda_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Add ':IOKitPersonalities:HDA Hardware Config Resource:IOProbeScore' integer" $hda_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Set ':IOKitPersonalities:HDA Hardware Config Resource:IOProbeScore' 2000" $hda_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Merge $resources/ahhcd.plist ':IOKitPersonalities:HDA Hardware Config Resource'" $hda_injector/Contents/Info.plist
}

if [[ ! -d $resources ]]; then
    echo "Usage: create_hdainjector.sh {HDA resources folder}"
    echo "Example: create_hdainjector.sh Resouces_CX20751"
    exit 1
fi

createHDAInjector
