#!/bin/bash

DIR=$(dirname $0)

hcd_native=/System/Library/Extensions/AppleHDA.kext/Contents/PlugIns/AppleHDAHardwareConfigDriver.kext

function showOptions() {
    echo "-c,  Codec name."
    echo "-r,  Codec resources folder."
    echo "-o,  Output directory."
    echo "Usage: $(basename $0) [-r <HDA resources folder>] [-c <Codec name>] [-o <Output directory>]"
    echo "Example: $(basename $0) -r Resouces_CX20751 -c CX20751"
}

function createHCDInjector() {
# $1: Codec name
# $2: Resources folder
# $3: Output directory
    hcd_injector=$3/AppleHDAHCD_$1.kext

    echo "Creating $(basename $hcd_injector)"

    rm -Rf $hcd_injector && mkdir -p $hcd_injector/Contents
    cp $hcd_native/Contents/Info.plist $hcd_injector/Contents

    $DIR/fix_info_versions.sh $hcd_injector/Contents/Info.plist

    /usr/libexec/PlistBuddy -c "Delete ':BuildMachineOSBuild'" $hcd_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Delete ':DTCompiler'" $hcd_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Delete ':DTPlatformBuild'" $hcd_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Delete ':DTPlatformVersion'" $hcd_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Delete ':DTSDKBuild'" $hcd_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Delete ':DTSDKName'" $hcd_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Delete ':DTXcode'" $hcd_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Delete ':DTXcodeBuild'" $hcd_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Delete ':OSBundleLibraries'" $hcd_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Delete ':CFBundleExecutable'" $hcd_injector/Contents/Info.plist

    /usr/libexec/PlistBuddy -c "Set ':CFBundleIdentifier' 'org.the-braveknight.AppleHDAHCDInjector'" $hcd_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Set ':CFBundleName' 'AppleHDAHCDInjector'" $hcd_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Delete ':IOKitPersonalities:HDA Hardware Config Resource:PostConstructionInitialization'" $hcd_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Delete ':IOKitPersonalities:HDA Hardware Config Resource:HDAConfigDefault'" $hcd_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Merge $2/ahhcd.plist ':IOKitPersonalities:HDA Hardware Config Resource'" $hcd_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Add ':IOKitPersonalities:HDA Hardware Config Resource:IOProbeScore' integer" $hcd_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Set ':IOKitPersonalities:HDA Hardware Config Resource:IOProbeScore' 2000" $hcd_injector/Contents/Info.plist
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

createHCDInjector $codec $resources $directory
