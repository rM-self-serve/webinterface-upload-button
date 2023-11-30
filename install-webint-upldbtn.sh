#!/usr/bin/env bash
# Copyright (c) 2023 rM-self-serve
# SPDX-License-Identifier: MIT

upldbtn_sha256sum='38fd02d34289c102d71219b234a0ed2bdf8a79073b815585438cf3f4fb4b64f0'

release='v1.0.0'

installfile='./install-webint-upldbtn.sh'
pkgname='webinterface-upload-button'
localbin='/home/root/.local/bin'
binfile="${localbin}/${pkgname}"
aliasfile="${localbin}/webint-upldbtn"

remove_installfile() {
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

echo "${pkgname} ${release}"
echo "This program will add an upload button to the web interface."
echo 'Included funtionality to revert modification.'
echo ''
echo "This program will be installed in ${localbin}"
echo "${localbin} will be added to the path in ~/.bashrc if necessary"
echo ''
read -r -p "Would you like to continue with installation? [y/N] " response
case "$response" in
[yY][eE][sS] | [yY])
	echo "Installing ${pkgname}"
	;;
*)
	remove_installfile
	exit
	;;
esac

mkdir -p $localbin

case :$PATH: in
*:$localbin:*) ;;
*) echo "PATH=\"${localbin}:\$PATH\"" >>/home/root/.bashrc ;;
esac

pkg_sha_check() {
	if sha256sum -c <(echo "$upldbtn_sha256sum  $binfile") >/dev/null 2>&1; then
		return 0
	else
		return 1
	fi
}

sha_fail() {
	echo "sha256sum did not pass, error downloading ${pkgname}"
	echo "Exiting installer and removing installed files"
	[[ -f $binfile ]] && rm $binfile
	remove_installfile
	exit
}

[[ -f $binfile ]] && rm $binfile
wget "https://github.com/rM-self-serve/${pkgname}/releases/download/${release}/${pkgname}" \
	-O "$binfile"

if ! pkg_sha_check; then
	sha_fail
fi

chmod +x $binfile
ln -s $binfile $aliasfile

echo ""
echo "Finished installing ${pkgname}"
echo ""
echo "To use ${pkgname}, run:"
echo "$ webint-upldbtn apply"
echo ""

remove_installfile
