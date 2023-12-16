#!/usr/bin/env bash
# Copyright (c) 2023 rM-self-serve
# SPDX-License-Identifier: MIT

upldbtn_sha256sum='c2c873b0a4859e2fd038ed9fb9889ca0c70ec530dda33c00adb17c00312d2fd7'
js_sha256sum='d95e332f64bf9e5a3bd77f31845657fdbc15e3edce52b33de1ccee88845d3c47'

release='v1.1.1'

installfile='./install-webint-upldbtn.sh'
pkgname='webinterface-upload-button'
localbin='/home/root/.local/bin'
binfile="$localbin/$pkgname"
jsname="$pkgname.js"
jsfile="/usr/share/remarkable/webui/$jsname"

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

install() {
	echo "${pkgname} ${release}"
	echo "Add an upload button to the web interface."
	echo 'Ability to revert modification.'
	echo ''
	echo "This program will be installed in ${localbin}"
	echo "${localbin} will be added to the path in ~/.bashrc if necessary"
	echo ''

	mkdir -p $localbin
	case :$PATH: in
	*:$localbin:*) ;;
	*) echo "PATH=\"${localbin}:\$PATH\"" >>/home/root/.bashrc ;;
	esac

	[[ -f $binfile ]] && revert_mod && remove_install_files 
	wget "https://github.com/rM-self-serve/${pkgname}/releases/download/${release}/${pkgname}" \
		-O "$binfile"
	if ! sha_check "$upldbtn_sha256sum" "$binfile"; then
		sha_fail
	fi
	chmod +x $binfile

	[[ -f $jsfile ]] && rm $jsfile
	wget "https://github.com/rM-self-serve/${pkgname}/releases/download/${release}/${jsname}" \
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
