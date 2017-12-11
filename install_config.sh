#!/bin/bash

config=config.plist

./check_directory.sh $config
if [ $? -ne 0 ]; then
    echo "No config.plist file found, exiting..."
    exit 1
fi

EFI=$(./mount_efi.sh)

echo Copying $config to $EFI/EFI/Clover
cp $config $EFI/EFI/Clover
