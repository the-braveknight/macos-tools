#!/bin/bash

tools_dir=$(dirname ${BASH_SOURCE[0]})
repo_dir=$(dirname $0)

source $tools_dir/_download_cmds.sh
source $tools_dir/_install_cmds.sh
source $tools_dir/_archive_cmds.sh
source $tools_dir/_config_cmds.sh
source $tools_dir/_hda_cmds.sh
source $tools_dir/_lilu_helper.sh

downloads_dir=$repo_dir/Downloads
hotpatch_dir=$repo_dir/Hotpatch/Downloads
local_kexts_dir=$repo_dir/Kexts

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

case "$1" in
    --download-requirements)
        rm -Rf $downloads_dir && mkdir -p $downloads_dir
        rm -Rf $hotpatch_dir && mkdir -p $hotpatch_dir

        # Bitbucket downloads
        for ((index=0; 1; index++)); do
            author=$(printValue "Downloads:Bitbucket:$index:Author" "$repo_plist")
            repo=$(printValue "Downloads:Bitbucket:$index:Repo" "$repo_plist")
            if [[ $? -ne 0 ]]; then break; fi
            name=$(printValue "Downloads:Bitbucket:$index:Name" "$repo_plist" 2> /dev/null)
            bitbucketDownload "$author" "$repo" "$downloads_dir" "$name"
        done

        # GitHub downloads
        for ((index=0; 1; index++)); do
            author=$(printValue "Downloads:GitHub:$index:Author" "$repo_plist")
            repo=$(printValue "Downloads:GitHub:$index:Repo" "$repo_plist")
            if [[ $? -ne 0 ]]; then break; fi
            name=$(printValue "Downloads:GitHub:$index:Name" "$repo_plist" 2> /dev/null)
            githubDownload "$author" "$repo" "$downloads_dir" "$name"
        done

        # Hotpatch SSDT downloads
        for ssdt in $(printArrayItems "Downloads:Hotpatch" "$repo_plist"); do
            downloadSSDT "$ssdt" "$hotpatch_dir"
        done
    ;;
    --install-apps)
        unarchiveAllInDirectory "$downloads_dir"
        for ((index=0; 1; index++)); do
            name=$(printValue "Installations:Apps:$index:Name" "$repo_plist" 2> /dev/null)
            if [[ $? -ne 0 ]]; then break; fi
            app=$(findApp "$name" "$downloads_dir")
            if [[ -e "$app" ]]; then
                installApp "$app"
            fi
        done
    ;;
    --install-tools)
        unarchiveAllInDirectory "$downloads_dir"
        for ((index=0; 1; index++)); do
            name=$(printValue "Installations:Tools:$index:Name" "$repo_plist" 2> /dev/null)
            if [[ $? -ne 0 ]]; then break; fi
            tool=$(findTool "$name" "$downloads_dir")
            if [[ -e "$tool" ]]; then
                installTool "$tool"
            fi
        done
    ;;
    --install-kexts)
        unarchiveAllInDirectory "$downloads_dir"
        for ((index=0; 1; index++)); do
            name=$(printValue "Installations:Kexts:$index:Name" "$repo_plist" 2> /dev/null)
            if [[ $? -ne 0 ]]; then break; fi
            kext=$(findKext "$name" "$downloads_dir" "$local_kexts_dir")
            if [[ -e "$kext" ]]; then
                installKext "$kext"
            fi
        done
    ;;
    --install-essential-kexts)
        unarchiveAllInDirectory "$downloads_dir"
        EFI=$($tools_dir/mount_efi.sh)
        efi_kexts_dest=$EFI/EFI/CLOVER/kexts/Other
        rm -Rf $efi_kexts_dest/*.kext
        for ((index=0; 1; index++)); do
            name=$(printValue "Installations:Kexts:$index:Name" "$repo_plist" 2> /dev/null)
            if [[ $? -ne 0 ]]; then break; fi
            essential=$(printValue "Installations:Kexts:$index:Essential" "$repo_plist" 2> /dev/null)
            kext=$(findKext "$name" "$downloads_dir" "$local_kexts_dir")
            if [[ -e "$kext" && "$essential" == "true" ]]; then
                installKext "$kext" "$efi_kexts_dest"
            fi
        done
    ;;
    --remove-installed-kexts)
        for kext in $(printInstalledItems "Kexts"); do
            removeKext "$kext"
        done
    ;;
    --remove-installed-apps)
        for app in $(printInstalledItems "Apps"); do
            removeApp "$app"
        done
    ;;
    --remove-installed-tools)
        for tool in $(printInstalledItems "Tools"); do
            removeTool "$tool"
        done
    ;;
    --remove-deprecated-kexts)
        for kext in $(printArrayItems "Deprecated:Kexts" "$repo_plist"); do
            removeKext "$kext"
        done
    ;;
    --install-config)
        installConfig "$config_plist"
    ;;
    --update-config)
        updateConfig "$config_plist"
    ;;
    --update-kernelcache)
        sudo kextcache -i /
    ;;
    --update)
        echo "Checking for updates..."
        git stash --quiet && git pull
        echo "Checking for macos-tools updates..."
        cd $tools_dir && git stash --quiet && git pull && cd ..
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
