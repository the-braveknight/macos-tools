#!/bin/bash

DIR=$(dirname $0)
build_dir=Build

hotpatch_dir=$1
dsl_files=$hotpatch_dir/*.dsl

$DIR/check_directory.sh $dsl_files
if [ $? -ne 0 ]; then
    echo "Usage: make_acpi.sh {hotpatch dsl directory}"
    echo "Usage: make_acpi.sh ~/Desktop/hotpatch"
    exit 1
fi

function compile() {
    iasl -p $2/$(basename $1 .dsl).aml $1
}

rm -Rf $build_dir && mkdir $build_dir

for dsl in $dsl_files; do
    compile $dsl $build_dir
done
