#!/bin/bash

DIR=$(dirname ${BASH_SOURCE[0]})

source $DIR/_plist_utils.sh

function updateConfig() {
# $1: New config.plist
    EFI=$($DIR/mount_efi.sh)
    current_plist=$EFI/EFI/Clover/config.plist
    echo Updating config.plist at $current_plist
    replaceDict ":ACPI" "$current_plist" "$1"
    replaceDict ":Boot" "$current_plist" "$1"
    replaceDict ":Devices" "$current_plist" "$1"
    replaceDict ":KernelAndKextPatches" "$current_plist" "$1"
    replaceDict ":SystemParameters" "$current_plist" "$1"
    replaceVar ":RtVariables:BooterConfig" "$current_plist" "$1"
    replaceVar ":RtVariables:CsrActiveConfig" "$current_plist" "$1"
}

function installConfig() {
# $1: New config.plist
    EFI=$($DIR/mount_efi.sh)
    current_plist=$EFI/EFI/Clover/config.plist
    echo "Copying $1 to $current_plist"
    cp "$1" $current_plist
}
