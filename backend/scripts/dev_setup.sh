#!/usr/bin/env bash
set -e

staring_dir=$(pwd)

# Move to directory where the script is located
function move_to_dir_with_this_script() {
	BASEDIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
	while [ -h "$BASEDIR/$0" ]; do
	    DIR=$(dirname -- "$BASEDIR/$0")
	    SYM=$(readlink $BASEDIR/$0)
	    BASEDIR=$(cd $DIR && cd $(dirname -- "$SYM") && pwd)
	done
	cd "${BASEDIR}"
}

# Check that a given command is installed
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

move_to_dir_with_this_script
cd ..

verify_installed "virtualenv"

echo "Setting up virtualenv"
virtualenv .cellar-venv
. .cellar-venv/bin/activate

echo "Installing dependencies"
pip install -r requirements.txt

venv_bin_path=$(realpath --relative-to=${staring_dir} $(cd .cellar-venv/bin && pwd))
echo "All done!"
echo "Now, use the following command to activate the virtualenv:"
echo
echo "  source ${venv_bin_path}/activate"
echo
