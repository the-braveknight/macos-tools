#!/bin/bash

DIR=$(dirname ${BASH_SOURCE[0]})

source $DIR/_plist_utils.sh

plist=$DIR/org.the-braveknight.essentials.plist

printArrayItems "Kexts" $plist
