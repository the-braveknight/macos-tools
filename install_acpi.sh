#!/bin/bash

aml_binaries=./Build/*.aml

./check_directory.sh $aml_binaries
if [ $? -ne 0 ]; then
    echo "No compiled AML binaries found in ./Build. Please run make_acpi.sh"
    exit 1
fi

EFI=$(./mount_efi.sh)

function installAML() {
    fileName=$(basename $1)
    echo Copying $fileName to $EFI/EFI/Clover/ACPI/patched
    cp $1 $EFI/EFI/Clover/ACPI/patched
}

for aml in $aml_binaries; do
    installAML $aml
done
