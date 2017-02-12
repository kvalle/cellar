#!/usr/bin/env bash

BASEDIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

while [ -h "$BASEDIR/$0" ]; do
    DIR=$(dirname -- "$BASEDIR/$0")
    SYM=$(readlink $BASEDIR/$0)
    BASEDIR=$(cd $DIR && cd $(dirname -- "$SYM") && pwd)
done
cd ${BASEDIR}


ENVS=$(eb list | sed 's/^\* //')

if [[ ${1} != cellar-* ]]; then
  echo "Usage: ${0} cellar-<environment>"
  exit 1
elif [ $(echo "$ENVS" | grep "^$1$" -c) -eq 0 ]; then
  echo "Environment not recognized: '$1'. Use one of the following:"
  echo
  echo "$ENVS"
  exit 1
fi

./package.sh "$1"

echo "> Starting deploy"
eb deploy "$1"
