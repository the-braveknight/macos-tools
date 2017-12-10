#!/bin/bash

function findKext() {
    if [[ "${@:2}" == "" ]]; then
        find ./ -path \*/$1 -not -path \*/PlugIns/* -not -path \*/Debug/*
    else
        find ${@:2} -path \*/$1 -not -path \*/PlugIns/* -not -path \*/Debug/*
    fi
}

findKext $@
