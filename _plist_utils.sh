#!/bin/bash

# Assume plist file is $plist

function printArrayItems() {
# $1: Array name (key) in root dictionary plist
    for ((index=0; 1; index++)); do
        kext=$(/usr/libexec/PlistBuddy -c "Print :$1:$index" $plist 2>&1)
        if [[ "$kext" == *"Does Not Exist"* ]]; then
            break
        fi
        echo $kext
    done
}

function addArray() {
    /usr/libexec/PlistBuddy -c "Add $1 Array" $plist &> /dev/null
}

function addDictionary() {
    /usr/libexec/PlistBuddy -c "Add $1 Dict" $plist &> /dev/null
}

function addString() {
    /usr/libexec/PlistBuddy -c "Add $1 String" $plist &> /dev/null
}

function addInteger() {
    /usr/libexec/PlistBuddy -c "Add $1 Integer" $plist &> /dev/null
}

function setValue() {
    /usr/libexec/PlistBuddy -c "Set $1 '$2'" $plist &> /dev/null
}

function printValue() {
    /usr/libexec/PlistBuddy -c "Print $1" $plist
}

function append() {
# $1: Array name (key) in root dictionary plist
# $2: Value type
# $3: Value
    for element in $(printArrayItems "$1"); do
        if [[ "$element" == "$3" ]]; then return; fi
    done
    addArray "$1"
    /usr/libexec/PlistBuddy -c "Add :$1:0 $2 '$3'" $plist &> /dev/null
}

function appendArrayWithString() {
# $1: Array name (key) in root dictionary plist
# $2: String value
    append "$1" "String" "$2"
}

function appendArrayWithInteger() {
# $1: Array name (key) in root dictionary plist
# $2: Integer value
    append "$1" "Integer" "$2"
}
