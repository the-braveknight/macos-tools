#!/bin/bash

DIR=$(dirname $0)

hda_native=/System/Library/Extensions/AppleHDA.kext
hcd_native=$hda_native/Contents/PlugIns/AppleHDAHardwareConfigDriver.kext

function showOptions() {
    echo "-c,  Codec name."
    echo "-r,  Codec resources folder."
    echo "-o,  Output directory."
    echo "-x,  Create XML AppleHDA injector. (PinConfigs to be injected with CodecCommander.kext)"
    echo "-p,  Create PinConfigs injector. (XML layouts to be created and copied to native AppleHDA resources)"
    echo "-z,  Create .zml.zlib resources."
    echo "-h,  Show this help message."
    echo "Usage: $(basename $0) [-c <Codec name>] [-r <HDA resources folder>] [-o <Output directory>]"
    echo "Example: $(basename $0) -c CX20751 -r Resouces_CX20751"
}

function fixVersion() {
    oldValue=$(/usr/libexec/PlistBuddy -c "Print $1" $2)
    newValue=$(echo $oldValue | perl -p -e 's/(\d*\.\d*(\.\d*)?)/9\1/')
    /usr/libexec/PlistBuddy -c "Set $1 '$newValue'" $2
}

function createZMLResources() {
# $1: Codec name
# $2: Resources folder
# $3: Output directory
    zml_resources=$3/AppleHDA_$1_Resources
    rm -Rf $zml_resources && mkdir $zml_resources

    for layout in $2/layout*.plist; do
        $DIR/zlib deflate $layout > $zml_resources/$(basename $layout .plist).zml.zlib
    done

    $DIR/zlib inflate $hda_native/Contents/Resources/Platforms.xml.zlib > /tmp/Platforms.plist
    /usr/libexec/PlistBuddy -c "Delete ':PathMaps'" /tmp/Platforms.plist
    /usr/libexec/PlistBuddy -c "Merge $2/Platforms.plist" /tmp/Platforms.plist
    $DIR/zlib deflate /tmp/Platforms.plist > $zml_resources/Platforms.zml.zlib
}

function createXMLInjector() {
# $1: Codec name
# $2: Resources folder
# $3: Output directory
    hda_injector=$3/AppleHDA_$1.kext

    rm -Rf $hda_injector && mkdir -p $hda_injector/Contents/Resources && mkdir -p $hda_injector/Contents/MacOS
    ln -s $hda_native/Contents/MacOS/AppleHDA $hda_injector/Contents/MacOS/AppleHDA

    cp $hda_native/Contents/Info.plist $hda_injector/Contents/Info.plist

    fixVersion ":NSHumanReadableCopyright" $hda_injector/Contents/Info.plist
    fixVersion ":CFBundleVersion" $hda_injector/Contents/Info.plist
    fixVersion ":CFBundleGetInfoString" $hda_injector/Contents/Info.plist
    fixVersion ":CFBundleShortVersionString" $hda_injector/Contents/Info.plist

    for layout in $2/layout*.plist; do
        $DIR/zlib deflate $layout > $hda_injector/Contents/Resources/$(basename $layout .plist).xml.zlib
    done

    $DIR/zlib inflate $hda_native/Contents/Resources/Platforms.xml.zlib > /tmp/Platforms.plist
    /usr/libexec/PlistBuddy -c "Delete ':PathMaps'" /tmp/Platforms.plist
    /usr/libexec/PlistBuddy -c "Merge $2/Platforms.plist" /tmp/Platforms.plist
    $DIR/zlib deflate /tmp/Platforms.plist > $hda_injector/Contents/Resources/Platforms.xml.zlib
}

function createHCDInjector() {
# $1: Codec name
# $2: Resources folder
# $3: Output directory
    hcd_injector=$3/AppleHDAHCD_$1.kext

    rm -Rf $hcd_injector && mkdir -p $hcd_injector/Contents
    cp $hcd_native/Contents/Info.plist $hcd_injector/Contents

    fixVersion ":NSHumanReadableCopyright" $hcd_injector/Contents/Info.plist
    fixVersion ":CFBundleVersion" $hcd_injector/Contents/Info.plist
    fixVersion ":CFBundleGetInfoString" $hcd_injector/Contents/Info.plist
    fixVersion ":CFBundleShortVersionString" $hcd_injector/Contents/Info.plist

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

function createHDAInjector() {
# $1: Codec name
# $2: Resources folder
# $3: Output directory
    hda_injector=$3/AppleHDA_$1.kext

    createXMLInjector $1 $2 $3

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

while getopts c:r:o:xzph option; do
    case $option in
    c)
        codec=$OPTARG
    ;;
    r)
        resources=$OPTARG
    ;;
    o)
        directory=$OPTARG
    ;;
    x)
        xmlInjector=1
    ;;
    z)
        zmlInjector=1
    ;;
    p)
        hcdInjector=1
    ;;
    h)
        showOptions
        exit 0
    ;;
    esac
done

shift $((OPTIND-1))

if [[ ! -d $directory ]]; then directory=.; fi

if [[ ! -n $resources || ! -d $resources ]]; then showOptions; exit 1; fi

if [[ $hcdInjector ]]; then
    createHCDInjector $codec $resources $directory
elif [[ $xmlInjector ]]; then
    createXMLInjector $codec $resources $directory
elif [[ $zmlInjector ]]; then
    createZMLResources $codec $resources $directory
else
    createHDAInjector $codec $resources $directory
fi
