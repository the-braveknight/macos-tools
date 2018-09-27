#!/bin/bash

PlistBuddy=/usr/libexec/PlistBuddy

function printValue() {
# $1: Key name
# $2: Plist file
    $PlistBuddy -c "Print '$1'" "$2"
}

function printObject() {
# For dictionaries and arrays
# $1: Dictionary name
# $2: Source plist file
    $PlistBuddy -x -c "Print '$1'" "$2"
}

function printArrayItems() {
# $1: Array name (key) in root dictionary plist
# $2: Plist file
    for ((index=0; 1; index++)); do
        item=$(printValue "$1:$index" "$2" 2>&1)
        if [[ "$item" == *"Does Not Exist"* ]]; then break; fi
        echo $item
    done
}

function setValue() {
# $1: Key name
# $2: Value
# $3: Plist file
    $PlistBuddy -c "Set '$1' '$2'" "$3" &> /dev/null
}

function add() {
# $1: Item name (key)
# $2: Value type
# $3: Value
# $4: Plist file
    $PlistBuddy -c "Add '$1' $2" "$4" &> /dev/null
    setValue "$1" "$3" "$4"
}

function addArray() {
# $1: Array name
# $2: Plist file
    $PlistBuddy -c "Add $1 Array" "$2" &> /dev/null
}

function addDictionary() {
# $1: Dictionary name
# $2: Plist file
    $PlistBuddy -c "Add $1 Dict" "$2" &> /dev/null
}

function addString() {
# $1: String name
# $2: String value
# $3: Plist file
    add "$1" "String" "$2" "$3"
}

function addInteger() {
# $1: Integer name
# $2: Integer value
# $3: Plist file
    add "$1" "Integer" "$2" "$3"
}

function delete() {
# $1: Key name
# $2: Plist file
    $PlistBuddy -c "Delete '$1'" "$2"
}

function mergePlist() {
# $1: Plist to be merged
# $2: New key in address
# $3: Parent plist to be merged into
    $PlistBuddy -c "Merge $1 '$2'" "$3"
}

function copy() {
# $1: Key to copy
# $2: Destination key
# $3: Plist file
    $PlistBuddy -c "Copy '$1' '$2'" "$3"
}

function append() {
# $1: Array name (key) in root dictionary plist
# $2: Value type
# $3: Value
# $4: Plist file
    add "$1:0" "$2" "$3" "$4"
}

function appendArrayWithString() {
# $1: Array name (key) in root dictionary plist
# $2: String value
# $3: Plist file
    append "$1" "String" "$2" "$3"
}

function appendArrayWithInteger() {
# $1: Array name (key) in root dictionary plist
# $2: Integer value
# $3: Plist file
    append "$1" "Integer" "$2" "$3"
}
