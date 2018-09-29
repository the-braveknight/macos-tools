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

function removeKext() {
    sudo rm -Rf $kexts_dest/$1 /Library/Extensions/$1 /System/Library/Extensions/$1
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
        installKextsInDirectory "$downloads_dir" "$exceptions"
        $0 --install-hdainjector
        $0 --install-backlightinjector
    ;;
    --install-essential-kexts)
        unarchiveAllInDirectory "$downloads_dir"
        EFI=$($DIR/mount_efi.sh)
        efi_kext_dest=$EFI/EFI/CLOVER/kexts/Other
        rm -Rf $kext_dest/*.kext
        for kext in $($DIR/essential_kexts.sh); do
            installKext $(findKext "$kext" "$downloads_dir" "$local_kexts_dir") "$efi_kext_dest"
        done
    ;;
    --install-hdainjector)
        createHDAInjector "$hda_codec" "Resources_$hda_codec" "$local_kexts_dir"
        installKext "$local_kexts_dir/AppleHDA_$hda_codec.kext"
    ;;
    --install-backlightinjector)
        installKext "$local_kexts_dir/AppleBacklightInjector.kext"
    ;;
    --remove-installed-kexts)
        # Remove kexts that have been installed by this script previously
        for kext in $($DIR/installed_kexts.sh); do
            removeKext $kext
        done
    ;;
    --remove-deprecated-kexts)
        # Remove deprecated kexts
        # More info: https://github.com/the-braveknight/macos-tools/blob/master/org.the-braveknight.deprecated.plist
        for kext in $($DIR/deprecated_kexts.sh); do
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
        cd macos-tools && git stash --quiet && git pull && cd ..
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
