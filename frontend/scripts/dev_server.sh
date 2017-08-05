#!/usr/bin/env bash
set -e

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

move_to_dir_with_this_script
cd ../dist

python -m SimpleHTTPServer 8000
