#!/bin/bash

config=./config.plist

if [ ! -e $config ]; then
    echo "No config.plist file found, exiting..."
    exit 1
fi

EFI=$(./mount_efi.sh)

cp $config $EFI/EFI/Clover
