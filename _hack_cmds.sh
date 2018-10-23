#!/bin/bash

tools_dir=$(dirname ${BASH_SOURCE[0]})
repo_dir=$(dirname $0)

source $tools_dir/_download_cmds.sh
source $tools_dir/_install_cmds.sh
source $tools_dir/_archive_cmds.sh
source $tools_dir/_config_cmds.sh
source $tools_dir/_hda_cmds.sh
source $tools_dir/_lilu_helper.sh

if [[ ! -d "$downloads_dir" ]]; then
    downloads_dir=$repo_dir/Downloads
fi

if [[ ! -d "$hotpatch_dir" ]]; then
    hotpatch_dir=$repo_dir/Hotpatch/Downloads
fi

if [[ ! -d "$local_kexts_dir" ]]; then
    local_kexts_dir=$repo_dir/Kexts
fi

if [[ ! -d "$build_dir" ]]; then
    if [[ ! -d "$repo_dir/Build" ]]; then mkdir $repo_dir/Build; fi
    build_dir=$repo_dir/Build
fi

if [[ -z "$repo_plist" ]]; then
    if [[ -e "$repo_dir/repo_config.plist" ]]; then
        repo_plist=$repo_dir/repo_config.plist
    else
        echo "No repo_config.plist file found. Exiting..."
        exit 1
    fi
fi

if [[ -z "$config_plist" ]]; then
    if [[ -e "$repo_dir/config.plist" ]]; then
        config_plist=$repo_dir/config.plist
    else
        echo "No config.plist file found. Exiting..."
        exit 2
    fi
fi

exceptions="$(printArrayItems Exceptions $repo_plist)"
hda_codec="$(printValue Codec $repo_plist)"

function downloadRehabManToolsFromPlist() {
# $1: Downloads directory
    for download in $(printArrayItems "Downloads:RehabMan" "$repo_plist"); do
        bitbucketDownload RehabMan "$download" "$1"
    done
}

function downloadAcidantheraToolsFromPlist() {
# $1: Downloads directory
    for download in $(printArrayItems "Downloads:Acidanthera" "$repo_plist"); do
        githubDownload Acidanthera "$download" "$1"
    done
}

function downloadHotpatchSSDTsFromPlist() {
# $1: Downloads directory
    for ssdt in $(printArrayItems "Downloads:Hotpatch" "$repo_plist"); do
        downloadSSDT "$ssdt" "$1"
    done
}

function installed() {
# $1: Can be either 'Kexts', 'Apps', or 'Tools'.
    printInstalledItems "$1"
}

function deprecated() {
# $1: Can be either 'Kexts', 'Apps', or 'Tools'.
    printArrayItems "Deprecated:$1" "$repo_plist"
}

function essential() {
# $1: Can be either 'Kexts', 'Apps', or 'Tools'.
    printArrayItems "Essentials:$1" "$repo_plist"
}

case "$1" in
    --download-requirements)
        rm -Rf $downloads_dir && mkdir -p $downloads_dir
        downloadRehabManToolsFromPlist "$downloads_dir"
        downloadAcidantheraToolsFromPlist "$downloads_dir"

        rm -Rf $hotpatch_dir && mkdir -p $hotpatch_dir
        downloadHotpatchSSDTsFromPlist "$hotpatch_dir"
    ;;
    --install-apps)
        unarchiveAllInDirectory "$downloads_dir"
        installAppsInDirectory "$downloads_dir" "$exceptions"
    ;;
    --install-tools)
        unarchiveAllInDirectory "$downloads_dir"
        installToolsInDirectory "$downloads_dir" "$exceptions"
    ;;
    --build-required-kexts)
        createHDAInjector "$hda_codec" "Resources_$hda_codec" "$build_dir"
        createLiluHelper "$build_dir"
    ;;
    --install-kexts)
        unarchiveAllInDirectory "$downloads_dir"
        installKextsInDirectory "$downloads_dir" "$exceptions"
        installKextsInDirectory "$build_dir" "$exceptions"
        if [[ -d "$local_kexts_dir" ]]; then
            installKextsInDirectory "$local_kexts_dir" "$exceptions"
        fi
    ;;
    --install-essential-kexts)
        unarchiveAllInDirectory "$downloads_dir"
        EFI=$($tools_dir/mount_efi.sh)
        efi_kexts_dest=$EFI/EFI/CLOVER/kexts/Other
        rm -Rf $efi_kexts_dest/*.kext
        for kext in $(essential "Kexts"); do
            installKext $(findKext "$kext" "$downloads_dir" "$build_dir" "$local_kexts_dir") "$efi_kexts_dest"
        done
    ;;
    --remove-installed-kexts)
        # Remove kexts that have been installed by this script previously
        for kext in $(installed "Kexts"); do
            removeKext $kext
        done
    ;;
    --remove-deprecated-kexts)
        # Remove deprecated kexts
        # More info: https://github.com/the-braveknight/macos-tools/blob/master/org.the-braveknight.deprecated.plist
        for kext in $(deprecated "Kexts"); do
            removeKext $kext
        done
    ;;
    --install-config)
        installConfig $config_plist
    ;;
    --update-config)
        updateConfig $config_plist
    ;;
    --update-kernelcache)
        sudo kextcache -i /
    ;;
    --update)
        echo "Checking for updates..."
        git stash --quiet && git pull
        echo "Checking for macos-tools updates..."
        cd $macos_tools && git stash --quiet && git pull && cd ..
    ;;
    --install-downloads)
        $0 --install-tools
        $0 --install-apps
        $0 --remove-deprecated-kexts
        $0 --build-required-kexts
        $0 --install-essential-kexts
        $0 --install-kexts
        $0 --update-kernelcache
    ;;
esac
