#!/bin/bash

DIR=$(dirname $0)

source $DIR/_plist_utils.sh

plist=$DIR/org.the-braveknight.deprecated.plist

function printDeprecatedItems() {
# $1: Array name (key) in root dictionary plist
    printItems "$1"
}
