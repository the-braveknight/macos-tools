#!/bin/bash

DIR=$(dirname ${BASH_SOURCE[0]})

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
# $2: Item
    for item in $(printInstalledItems "$1"); do
        if [[ "$item" == "$2" ]]; then return; fi
    done
    addArray "$1" "$plist"
    appendArrayWithString "$1" "$2" "$plist"
}

function removeInstalledItem() {
# $1: Array key
# $2: Item
    index=$(indexForItemInArray "$1" "$2" "$plist")
    if [[ -n "$index" ]]; then
        removeItem "$1:$index" "$plist"
    fi
}
