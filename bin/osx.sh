#!/bin/bash
version=$(sw_vers -productVersion)
#a=( ${version//./ } )
a1="$(cut -d'.' -f1 <<<"$version")"
a2="$(cut -d'.' -f2 <<<"$version")"
#DARWINVERSION="${a[0]}.${a[1]}"
DARWINVERSION="$a1.$a2"
ARCH=$(uname -m)
OSXDEST=""
PUPPETDMG="puppet-agent-latest.dmg"
OSXDMG="https://downloads.puppetlabs.com/mac/puppet5/$DARWINVERSION/$ARCH/$PUPPETDMG"

# check if wget is installed
if ! command -v wget # result=127 => command not found
then
    echo "wget is required and not installed! The installation is aborted!"
    exit 1
fi