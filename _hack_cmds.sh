#!/bin/bash

DIR=$(dirname ${BASH_SOURCE[0]})

source $DIR/_download_cmds.sh
source $DIR/_install_cmds.sh
source $DIR/_archive_cmds.sh
source $DIR/_config_cmds.sh
source $DIR/_hda_cmds.sh

# Required declarations:
#downloads_dir=Downloads/Kexts
#local_kexts_dir=Kexts
#hotpatch_dir=Hotpatch/Downloads
#repo_plist=org.the-braveknight.y520.plist

# Optional declarations:
#deprecated_plist=org.the-braveknight.deprecated.plist
#essentials_plist=org.the-braveknight.essentials.plist

if [[ -z "$deprecated_plist" ]]; then
    deprecated_plist=$DIR/org.the-braveknight.deprecated.plist
fi

if [[ -z "$essentials_plist" ]]; then
    essentials_plist=$DIR/org.the-braveknight.essentials.plist
fi

exceptions="$(printArrayItems Exceptions $repo_plist)"
hda_codec="$(printValue Codec $repo_plist)"

function downloadRehabManToolsFromPlist() {
# $1: Downloads directory
    for rehabman_download in $(printArrayItems "Downloads:RehabMan" "$repo_plist"); do
        bitbucketDownload RehabMan "$rehabman_download" "$1"
    done
}

function downloadAcidantheraToolsFromPlist() {
# $1: Downloads directory
    for acidanthera_download in $(printArrayItems "Downloads:Acidanthera" "$repo_plist"); do
        githubDownload Acidanthera "$acidanthera_download" "$1"
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
    printArrayItems "$1" "$deprecated_plist"
}

function essential() {
# $1: Can be either 'Kexts', 'Apps', or 'Tools'.
    printArrayItems "$1" "$essentials_plist"
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
    --install-kexts)
        unarchiveAllInDirectory "$downloads_dir"
        createHDAInjector "$hda_codec" "Resources_$hda_codec" "$local_kexts_dir"
        installKextsInDirectory "$downloads_dir" "$exceptions"
        installKextsInDirectory "$local_kexts_dir"
    ;;
    --install-essential-kexts)
        unarchiveAllInDirectory "$downloads_dir"
        EFI=$($DIR/mount_efi.sh)
        efi_kexts_dest=$EFI/EFI/CLOVER/kexts/Other
        rm -Rf $efi_kexts_dest/*.kext
        for kext in $(essential "Kexts"); do
            installKext $(findKext "$kext" "$downloads_dir" "$local_kexts_dir") "$efi_kexts_dest"
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
        $0 --install-essential-kexts
        $0 --install-kexts
        $0 --update-kernelcache
    ;;
esac
