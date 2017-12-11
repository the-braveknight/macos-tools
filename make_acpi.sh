#!/bin/bash

dsl_files=./hotpatch/*.dsl

./check_directory.sh $dsl_files
if [ $? -ne 0 ]; then
    echo "No DSL files in ./hotpatch. Exiting..."
    exit 1
fi

function compile() {
    iasl -p $2/$(basename $1 .dsl).aml $1
}

rm -Rf ./Build && mkdir ./Build

for dsl in $dsl_files; do
    compile $dsl ./Build
done
