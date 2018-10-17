#!/bin/bash

# Original idea from RehabMan

DIR=$(dirname ${BASH_SOURCE[0]})

source $DIR/_plist_utils.sh

kexts_directory=/Library/Extensions

function kextsWithLiluDependency() {
    kexts=$(find $kexts_directory -name "*.kext")
    for kext in $kexts; do
        local kext_plist=$kext/Contents/Info.plist
        printValue "OSBundleLibraries:as.vit9696.Lilu" "$kext_plist" > /dev/null
        if [[ $? -eq 0 ]]; then
            echo $kext
        fi
    done
}

function createLiluHelper() {
# $1: Output directory
    rm -Rf $1/LiluHelper.kext && mkdir -p $1/LiluHelper.kext/Contents
    local plist=$1/LiluHelper.kext/Contents/Info.plist

    addString "CFBundleDevelopmentRegion" "English" "$plist"
    addString "CFBundleGetInfoString" "LiluHelper 1.0, Copyright © 2018 the-braveknight. All rights reserved." "$plist"
    addString "CFBundleIdentifier" "com.apple.security.LiluHelper" "$plist"
    addString "CFBundleInfoDictionaryVersion" "6.0" "$plist"
    addString "CFBundleName" "LiluHelper" "$plist"
    addString "CFBundlePackageType" "KEXT" "$plist"
    addString "CFBundleVersion" "1.0" "$plist"

    addString "IOKitPersonalities:LiluHelper:CFBundleIdentifier" "com.apple.kpi.iokit" "$plist"
    addString "IOKitPersonalities:LiluHelper:IOClass" "IOService" "$plist"
    addString "IOKitPersonalities:LiluHelper:IOMatchCategory" "LiluHelper" "$plist"
    addString "IOKitPersonalities:LiluHelper:IOProviderClass" "IOResources" "$plist"
    addString "IOKitPersonalities:LiluHelper:IOResourceMatch" "IOKit" "$plist"

    addString "OSBundleLibraries:com.apple.kpi.bsd" "12.0.0" "$plist"
    addString "OSBundleLibraries:com.apple.kpi.iokit" "12.0.0" "$plist"
    addString "OSBundleLibraries:com.apple.kpi.libkern" "12.0.0" "$plist"
    addString "OSBundleLibraries:com.apple.kpi.mach" "12.0.0" "$plist"
    addString "OSBundleLibraries:com.apple.kpi.unsupported" "12.0.0" "$plist"

    lilu=$kexts_directory/Lilu.kext
    lilu_version=$(printValue "OSBundleCompatibleVersion" "$lilu/Contents/Info.plist")
    addString "OSBundleLibraries:as.vit9696.Lilu" "$lilu_version" "$plist"

    for kext in $(kextsWithLiluDependency); do
        local kext_plist=$kext/Contents/Info.plist
        local identifier=$(printValue "CFBundleIdentifier" "$kext_plist")
        local version=$(printValue "CFBundleVersion" "$kext_plist")
        addString "OSBundleLibraries:$identifier" "$version" "$plist"
    done
}
