#!/bin/bash

DIR=$(dirname $0)

resources=$1

hcd_native=/System/Library/Extensions/AppleHDA.kext/Contents/PlugIns/AppleHDAHardwareConfigDriver.kext

function createHCDInjector() {
    hcd_injector=AppleHDAHCDInjector.kext

    echo "Creating $hcd_injector"

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
    /usr/libexec/PlistBuddy -c "Merge $resources/ahhcd.plist ':IOKitPersonalities:HDA Hardware Config Resource'" $hcd_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Add ':IOKitPersonalities:HDA Hardware Config Resource:IOProbeScore' integer" $hcd_injector/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Set ':IOKitPersonalities:HDA Hardware Config Resource:IOProbeScore' 2000" $hcd_injector/Contents/Info.plist
}

if [[ ! -d $resources ]]; then
    echo "Usage: create_hcdinjector.sh {HDA resources folder}"
    echo "Example: create_hcdinjector.sh Resouces_CX20751"
    exit 1
fi

createHCDInjector
