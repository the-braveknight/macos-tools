#!/bin/bash

DIR=$(dirname $0)

new_config=$1

if [[ ! -e $new_config ]]; then
    echo "Usage: update_config.sh {new Clover config.plist}"
    echo "Example: update_config.sh ~/Desktop/config.plist"
    exit 1
fi

EFI=$($DIR/mount_efi.sh /)
current_config=$EFI/EFI/Clover/config.plist

function replaceVar() {
    value=$(/usr/libexec/plistbuddy -c "Print '$1'" $new_config)
    /usr/libexec/plistbuddy -c "Set '$1' '$value'" $current_config
}

function replaceDict() {
    /usr/libexec/plistbuddy -x -c "Print '$1'" $new_config > /tmp/org_rehabman_node.plist
    /usr/libexec/plistbuddy -c "Delete '$1'" $current_config
    /usr/libexec/plistbuddy -c "Add '$1' dict" $current_config
    /usr/libexec/plistbuddy -c "Merge /tmp/org_rehabman_node.plist '$1'" $current_config
}

# existing config.plist, preserve:
#   CPU
#   DisableDrivers
#   GUI
#   RtVariables, except CsrActiveConfig and BooterConfig
#   SMBIOS
#
# replaced are:
#   ACPI
#   Boot
#   Devices
#   KernelAndKextPatches
#   SystemParameters
#   RtVariables:BooterConfig
#   RtVariables:CsrActiveConfig

echo The config.plist at $current_config will be updated.

replaceDict ":ACPI"
replaceDict ":Boot"
replaceDict ":Devices"
replaceDict ":KernelAndKextPatches"
replaceDict ":SystemParameters"
replaceVar ":RtVariables:BooterConfig"
replaceVar ":RtVariables:CsrActiveConfig"
