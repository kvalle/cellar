#!/usr/bin/env bash

BASEDIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

# resolve symlinks
while [ -h "$BASEDIR/$0" ]; do
    DIR=$(dirname -- "$BASEDIR/$0")
    SYM=$(readlink $BASEDIR/$0)
    BASEDIR=$(cd $DIR && cd $(dirname -- "$SYM") && pwd)
done
cd ${BASEDIR}

echo "> Preparing"
mkdir -p tmp
if [[ -f tmp/app.zip ]]; then
	rm tmp/app.zip
fi

if [ ! -f config.py ]; then
	echo "Config file seems to be missing. Aborting."
	exit 1
fi

echo "> Packaging app"
zip --quiet --recurse-paths --exclude=".elasticbeanstalk/config.yml" \
	tmp/app.zip \
	.elasticbeanstalk/ \
	.ebextensions/ \
	application.py \
	auth.py \
	config.py \
	data.py \
	sync-with-s3.py \
	requirements.txt
