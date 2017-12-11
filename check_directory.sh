#!/bin/bash

# Success: 0
# Failure: 1
function checkDirectory() {
    for x in $1; do
        if [ -e "$x" ]; then
            return 0
        else
            return 1
        fi
    done
}

checkDirectory $@
