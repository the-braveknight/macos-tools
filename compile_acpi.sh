#!/bin/bash

DIR=$(dirname $0)

function compile() {
    iasl -p Build/$(basename $1 .dsl).aml $1
}

if [[ ! -d Build ]]; then mkdir Build; fi

if [[ ! -e $1 ]]; then
    echo "Usage: compile_acpi.sh {DSL to compile}"
    echo "Example: compile_acpi.sh ./SSDT-HDEF.dsl"
    exit 1
fi

for dsl in $@; do
    compile $dsl
done
