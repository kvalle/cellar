#!/usr/bin/env bash
set -e

staring_dir=$(pwd)

function move_to_dir_with_this_script() {
	BASEDIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
	while [ -h "$BASEDIR/$0" ]; do
	    DIR=$(dirname -- "$BASEDIR/$0")
	    SYM=$(readlink $BASEDIR/$0)
	    BASEDIR=$(cd $DIR && cd $(dirname -- "$SYM") && pwd)
	done
	cd "${BASEDIR}"
}

function verify_installed() {
	command_name="$1"
	
	if ! cmd_loc="$(type -p "${command_name}")" || [ -z "${cmd_loc}" ]; then
		echo >&2 "Aborting."
		echo >&2
		echo >&2 "  Error: ${command_name} is not installed."
		echo >&2
		echo >&2 "  You may have ment to run this script in the Vagrant environment, "
		echo >&2 "  or else you need to install ${command_name} before proceding."
		exit 1
	fi
}

function print_usage() {
	echo "Usage: ${0} ENV"
	echo
	echo "ENV must be one of: dev / test / prod."
}

move_to_dir_with_this_script
cd ..

verify_installed "ansible-vault"

environment="${1}"

if [[ "$#" != "1" ]]; then
	print_usage
    exit 1
elif ! $(grep -E '^(dev|test|prod)$' <<< "${environment}" > /dev/null) ; then
    print_usage
    exit 1
fi

echo "Preparing ${environment} config"
ansible-vault decrypt --output="app/config.py" "config/config_${environment}.py"

echo "Starting deploy"
zappa update "${environment}"
