#!/bin/bash

DIR=$(dirname $0)

hda_native=/System/Library/Extensions/AppleHDA.kext
hcd_native=$hda_native/Contents/PlugIns/AppleHDAHardwareConfigDriver.kext

function showOptions() {
    echo "-c,  Codec name."
    echo "-r,  Codec resources folder."
    echo "-o,  Output directory."
    echo "Usage: $(basename $0) [-r <HDA resources folder>] [-c <Codec name>] [-o <Output directory>]"
    echo "Example: $(basename $0) -r Resouces_CX20751 -c CX20751"
}

function createHDAInjector() {
# $1: Codec name
# $2: Resources folder
# $3: Output directory
    hda_injector=$3/AppleHDA_$1.kext

    $DIR/create_xmlinjector.sh -c $1 -r $2 -o $3

    /usr/libexec/PlistBuddy -c "Add ':HardwareConfigDriver_Temp' dict" $hda_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Merge $hcd_native/Contents/Info.plist ':HardwareConfigDriver_Temp'" $hda_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Copy ':HardwareConfigDriver_Temp:IOKitPersonalities:HDA Hardware Config Resource' ':IOKitPersonalities:HDA Hardware Config Resource'" $hda_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Delete ':HardwareConfigDriver_Temp'" $hda_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Delete ':IOKitPersonalities:HDA Hardware Config Resource:HDAConfigDefault'" $hda_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Delete ':IOKitPersonalities:HDA Hardware Config Resource:PostConstructionInitialization'" $hda_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Add ':IOKitPersonalities:HDA Hardware Config Resource:IOProbeScore' integer" $hda_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Set ':IOKitPersonalities:HDA Hardware Config Resource:IOProbeScore' 2000" $hda_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Merge $2/ahhcd.plist ':IOKitPersonalities:HDA Hardware Config Resource'" $hda_injector/Contents/Info.plist
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

shift $((OPTIND-1))

if [[ ! -d $directory ]]; then directory=.; fi

if [[ ! -d $resources || ! -n $codec ]]; then
    showOptions
    exit 1
fi

createHDAInjector $codec $resources $directory
