#!/bin/bash

DIR=$(dirname $0)

source $DIR/_plist_utils.sh

EFI=$($DIR/mount_efi.sh)
current_plist=$EFI/EFI/Clover/config.plist

function showOptions() {
    echo "-u,  Update only relevant settings. (Preserve user settings like SMBIOS)"
    echo "-h,  Show this help message."
    echo "Usage: $(basename $0) [Options] [New config.plist]"
    echo "Example: $(basename $0) -u ~/Downloads/config.plist"
}

function replaceVar() {
# $1: Property key
# $2: New config.plist
    value=$(printValue "$1" $2)
    setValue "$1" "$value" $current_plist
}

function replaceDict() {
# $1: Property key
# $2: New config.plist
    printObject "$1" $2 > /tmp/org_rehabman_node.plist
    delete "$1" $current_plist
    addDictionary "$1" $current_plist
    mergePlist /tmp/org_rehabman_node.plist "$1" $current_plist
}

function replaceConfig() {
# $1: New config.plist
    echo Copying $1 to $current_plist
    cp $1 $current_plist
}

function updateConfig() {
# $1: New config.plist
    echo Updating config.plist at $current_plist
    replaceDict ":ACPI" $1
    replaceDict ":Boot" $1
    replaceDict ":Devices" $1
    replaceDict ":KernelAndKextPatches" $1
    replaceDict ":SystemParameters" $1
    replaceVar ":RtVariables:BooterConfig" $1
    replaceVar ":RtVariables:CsrActiveConfig" $1
}

while getopts uh option; do
    case $option in
        u)
            update=1
        ;;
        h)
            showOptions
            exit 0
        ;;
    esac
done

shift $((OPTIND-1))

if [[ ! -e $1 ]]; then showOptions; exit 1; fi

if [[ $update ]]; then
    updateConfig $1
else
    replaceConfig $1
fi
