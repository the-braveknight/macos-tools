#!/bin/bash

DIR=$(dirname $0)

if [[ ! -e $1 ]]; then
    echo "Usage: install_config.sh {Clover config.plist}"
    echo "Example: install_config.sh ~/Desktop/config.plist"
    exit 1
fi

EFI=$($DIR/mount_efi.sh)

echo Copying $1 to $EFI/EFI/Clover
cp $1 $EFI/EFI/Clover
