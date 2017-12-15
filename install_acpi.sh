#!/bin/bash

DIR=$(dirname $0)
EFI=$($DIR/mount_efi.sh)

function installAML() {
    fileName=$(basename $1)
    echo Copying $fileName to $EFI/EFI/Clover/ACPI/patched
    cp $1 $EFI/EFI/Clover/ACPI/patched
}

if [[ ! -e $1 ]]; then
    echo "Usage: install_acpi.sh {SSDT to install}"
    echo "Example: install_acpi.sh ~/Downloads/SSDT-IGPU.aml"
    exit 1
fi

for aml in $@; do
    installAML $aml
done
