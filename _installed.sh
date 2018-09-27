#!/bin/bash

DIR=$(dirname $0)

source $DIR/_plist_utils.sh

tbk=~/Library/the-braveknight
if [[ ! -d $tbk ]]; then mkdir $tbk; fi
plist=$tbk/org.the-braveknight.installed.plist

function printInstalledItems() {
# $1: Array name (key) in root dictionary plist
    printItems "$1"
}

function addInstalledItem() {
# $1: Array name (key) in root dictionary plist
# $2: Element
    addItem "$1" "$2"
}
