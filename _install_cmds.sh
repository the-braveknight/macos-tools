#!/bin/bash

DIR=$(dirname ${BASH_SOURCE[0]})

source $DIR/_installed.sh

kexts_dest=/Library/Extensions
tools_dest=/usr/local/bin
apps_dest=/Applications

if [[ ! -d $tools_dest ]]; then sudo mkdir $tools_dest; fi

function findKext() {
# $1: Kext
# $2: Directory
    find "${@:2}" -name "$1" -not -path \*/PlugIns/* -not -path \*/Debug/*
}

function findTool() {
# $1: Tool
# $2: Directory
    find "${@:2}" -name "$1" -type f -perm -u+x -not -path \*.kext/* -not -path \*.app/* -not -path \*/Debug/*
}

function findApp() {
# $1: App
# $2: Directory
    find "${@:2}" -name "$1"
}

function checkExceptions() {
# $1: Item (kext, tool, app, etc)
# $2: Exceptions string
    itemName=$(basename "$1")
    if [[ -z "$2" || $(echo "$itemName" | grep -vE "$2") ]]; then
        # Passed through exceptions
        return 0
    else
        # Did not pass through exceptions
        return 1
    fi
}

function installKext() {
# $1: Kext to install
# $2: Destination (default: /Library/Extensions)
    if [[ -d "$2" ]]; then local kexts_dest="$2"; fi
    kextName=$(basename $1)
    echo Installing $kextName to $kexts_dest
    sudo rm -Rf $kexts_dest/$kextName
    sudo cp -Rf $1 $kexts_dest
    addInstalledItem "Kexts" "$kextName"
}

function installKextsInDirectory() {
# $1: Directory
# $2: Destination (optional)
# $3: Exceptions string (optional)
    if [[ -d "$2" ]]; then
        local kexts_dest="$2"
        if [[ -n "$3" ]]; then
            local exceptions="$3"
        fi
    elif [[ -n "$2" ]]; then
        local exceptions="$2"
    fi

    for kext in $(findKext "*.kext" "$1"); do
        checkExceptions "$kext" "$exceptions"
        if [[ $? -eq 0 ]]; then
            installKext "$kext" "$kexts_dest"
        fi
    done
}

function installTool() {
# $1: Tool to install
# $2: Destination (default: /usr/local/bin)
    if [[ -d "$2" ]]; then local tools_dest="$2"; fi
    fileName=$(basename $1)
    echo Installing $fileName to $tools_dest
    sudo rm -f $(which $fileName)
    sudo cp -f $1 $tools_dest
    addInstalledItem "Tools" "$fileName"
}

function installToolsInDirectory() {
# $1: Directory
# $2: Destination (optional)
# $3: Exceptions string (optional)
    if [[ -d "$2" ]]; then
        local tools_dest="$2"
        if [[ -n "$3" ]]; then
            local exceptions="$3"
        fi
    elif [[ -n "$2" ]]; then
        local exceptions="$2"
    fi

    for tool in $(findTool "*" "$1"); do
        checkExceptions "$tool" "$exceptions"
        if [[ $? -eq 0 ]]; then
            installTool "$tool" "$tools_dest"
        fi
    done
}

function installApp() {
# $1: App to install
# $2: Destination (default: /Applications)
    if [[ -d "$2" ]]; then local apps_dest="$2"; fi
    appName=$(basename $1)
    echo Installing $appName to $apps_dest
    sudo rm -Rf $apps_dest/$appName
    cp -Rf $1 $apps_dest
    addInstalledItem "Apps" "$appName"
}

function installAppsInDirectory() {
# $1: Directory
# $2: Destination (optional)
# $3: Exceptions string (optional)
    if [[ -d "$2" ]]; then
        local tools_dest="$2"
        if [[ -n "$3" ]]; then
            local exceptions="$3"
        fi
    elif [[ -n "$2" ]]; then
        local exceptions="$2"
    fi

    for app in $(findApp "*.app" "$1"); do
        checkExceptions "$app" "$exceptions"
        if [[ $? -eq 0 ]]; then
            installApp "$app" "$apps_dest"
        fi
    done
}

function removeKext() {
# $1: Kext name
    sudo rm -Rf "$kexts_dest/$1"
    removeInstalledItem "Kexts" "$1"
}

function removeApp() {
# $1: App name
    sudo rm -Rf "$apps_dest/$1"
    removeInstalledItem "Apps" "$1"
}

function removeTool() {
# $1: Tool name
    sudo rm -Rf "$tools_dest/$1"
    removeInstalledItem "Tools" "$1"
}
