#!/usr/bin/env bash
set -e

BASEDIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

while [ -h "$BASEDIR/$0" ]; do
    DIR=$(dirname -- "$BASEDIR/$0")
    SYM=$(readlink $BASEDIR/$0)
    BASEDIR=$(cd $DIR && cd $(dirname -- "$SYM") && pwd)
done
cd ${BASEDIR}/..

echo "> Preparing"
mkdir -p dist
if [[ -f dist/app.zip ]]; then
	rm dist/app.zip
fi

ENV=$(echo "$1" | sed 's/cellar-//')

ansible-vault decrypt --output="app/config.py" "config/config_${ENV}.py"

echo "> Packaging app"
zip --quiet --recurse-paths --exclude=".elasticbeanstalk/config.yml" dist/app.zip \
	.elasticbeanstalk/ \
	.ebextensions/ \
	application.py \
	app/ \
	requirements.txt
