#!/bin/bash

DIR=$(dirname $0)

source $DIR/_plist_utils.sh

tbk=~/Library/the-braveknight
if [[ ! -d $tbk ]]; then mkdir $tbk; fi
plist=$tbk/org.the-braveknight.installed.plist

function printInstalledItems() {
# $1: Array name (key) in root dictionary plist
    printArrayItems "$1" "$plist"
}

function addInstalledItem() {
# $1: Array name (key) in root dictionary plist
# $2: Element
    appendArrayWithString "$1" "$2" "$plist"
}
