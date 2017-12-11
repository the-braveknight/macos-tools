#!/bin/bash

./check_directory.sh ./hotpatch
if [ $? -ne 0 ]; then
    echo "./hotpatch directory not found. Exiting..."
    exit 1
fi

dsl_files=./hotpatch/*.dsl

./check_directory.sh $dsl_files
if [ $? -ne 0 ]; then
    echo "No DSL files in ./hotpatch. Exiting..."
    exit 1
fi

function compile() {
    if [[ -e $1 && -d $2 ]]; then
        iasl -p $2/$(basename $1 .dsl).aml $1
    fi
}

rm -Rf ./Build && mkdir ./Build

for dsl in $dsl_files; do
    compile $dsl ./Build
done
