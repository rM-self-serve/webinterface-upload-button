#!/usr/bin/env bash

pkgname='webinterface-upload-button'
removefile='./remove-webint-upldbtn.sh'
localbin='/home/root/.local/bin'
binfile="${localbin}/${pkgname}"
aliasfile="${localbin}/webint-upldbtn"

printf "\nRemove webinterface-upload-button\n"
echo 'Make sure to revert the modifications before uninstalling'

read -r -p "Would you like to continue with removal? [y/N] " response
case "$response" in
[yY][eE][sS] | [yY])
	echo "Removing webinterface-upload-button"
	;;
*)
	echo "Exiting removal"
	[[ -f $removefile ]] && rm $removefile
	exit
	;;
esac

[[ -f $binfile ]] && rm $binfile
[[ -f $aliasfile ]] && rm $aliasfile

[[ -f $removefile ]] && rm $removefile

echo "Successfully removed webinterface-upload-button"
