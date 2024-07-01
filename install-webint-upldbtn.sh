#!/usr/bin/env bash
# Copyright (c) 2023 rM-self-serve
# SPDX-License-Identifier: MIT

upldbtn_sha256sum='6cc1c350fbcaf599f8a498050a1cb843501bd8615dc29449a15b303e08f88e4e'
js_sha256sum='6488bfce61b20912e097029942b8a77a4d8fabbafc69f53cbf1dbd634ecd6711'

release='v1.2.0'

installfile='./install-webint-upldbtn.sh'
pkgname='webinterface-upload-button'
localbin='/home/root/.local/bin'
binfile="$localbin/$pkgname"
jsname="$pkgname.js"
jsfile="/usr/share/remarkable/webui/$jsname"

wget_path=/home/root/.local/share/rM-self-serve/wget
wget_remote=http://toltec-dev.org/thirdparty/bin/wget-v1.21.1-1
wget_checksum=c258140f059d16d24503c62c1fdf747ca843fe4ba8fcd464a6e6bda8c3bbb6b5

main() {
	case "$@" in
	'install' | '')
		install
		;;
	'remove')
		remove
		;;
	*)
		echo 'input not recognized'
		cli_info
		exit 0
		;;
	esac

	remove_install_script
}

remove_install_script() {
	read -r -p "Would you like to remove installation script? [y/N] " response
	case "$response" in
	[yY][eE][sS] | [yY])
		printf "Exiting installer and removing script\n"
		[[ -f $installfile ]] && rm $installfile
		;;
	*)
		printf "Exiting installer and leaving script\n"
		;;
	esac
}

sha_check() {
	if sha256sum -c <(echo "$1  $2") >/dev/null 2>&1; then
		return 0
	else
		return 1
	fi
}

sha_fail() {
	echo "sha256sum did not pass, error downloading ${pkgname}"
	echo "Exiting installer and removing installed files"
	remove_install_files
	remove_install_script
	exit
}
install_wget() {
	if [ -f "$wget_path" ] && ! sha256sum -c <(echo "$wget_checksum  $wget_path") > /dev/null 2>&1; then
	    rm "$wget_path"
	fi
	if ! [ -f "$wget_path" ]; then
	    echo "Fetching secure wget"
	    # Download and compare to hash
	    mkdir -p "$(dirname "$wget_path")"
	    if ! wget -q "$wget_remote" --output-document "$wget_path"; then
		echo "Error: Could not fetch wget, make sure you have a stable Wi-Fi connection"
		exit 1
	    fi
	fi
	if ! sha256sum -c <(echo "$wget_checksum  $wget_path") > /dev/null 2>&1; then
	    echo "Error: Invalid checksum for the local wget binary"
	    exit 1
	fi
	chmod 755 "$wget_path"
}

install() {
	echo "${pkgname} ${release}"
	echo "Add an upload button to the web interface."
	echo 'Ability to revert modification.'
	echo ''
	echo "This program will be installed in ${localbin}"
	echo "${localbin} will be added to the path in ~/.bashrc if necessary"
	echo ''

	install_wget
	mkdir -p $localbin
	case :$PATH: in
	*:$localbin:*) ;;
	*) echo "PATH=\"${localbin}:\$PATH\"" >>/home/root/.bashrc ;;
	esac

	[[ -f $binfile ]] && revert_mod && remove_install_files 
	"$wget_path" "https://github.com/rM-self-serve/${pkgname}/releases/download/${release}/${pkgname}" \
		-O "$binfile"
	if ! sha_check "$upldbtn_sha256sum" "$binfile"; then
		sha_fail
	fi
	chmod +x $binfile

	[[ -f $jsfile ]] && rm $jsfile
	"$wget_path" "https://github.com/rM-self-serve/${pkgname}/releases/download/${release}/${jsname}" \
		-O "$jsfile"
	if ! sha_check "$js_sha256sum" "$jsfile"; then
		sha_fail
	fi

	$binfile apply -y
	echo ""
	echo "${pkgname} applied"
	echo ""
}

remove() {
	revert_mod
	remove_install_files
	echo ""
	echo "${pkgname} reverted"
	echo ""
}

remove_install_files() {
	[[ -f $binfile ]] && rm $binfile
	[[ -f $jsfile ]] && rm $jsfile
}

revert_mod() {
	set -e
	if ! [[ -f $binfile ]]; then
		echo "$binfile could not be found, can not revert"
		exit 1
	fi

	$binfile revert -y
}

main "$@"
