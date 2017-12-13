#!/bin/bash

DIR=$(dirname $0)

config=$1

if [[ ! -e $config ]]; then
    echo "Usage: install_config.sh {Clover config.plist}"
    echo "Example: install_config.sh ~/Desktop/config.plist"
    exit 1
fi

EFI=$($DIR/mount_efi.sh)

echo Copying $config to $EFI/EFI/Clover
cp $config $EFI/EFI/Clover
