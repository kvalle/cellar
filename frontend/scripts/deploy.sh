#/bin/bash

BASEDIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
while [ -h "$BASEDIR/$0" ]; do
    DIR=$(dirname -- "$BASEDIR/$0")
    SYM=$(readlink $BASEDIR/$0)
    BASEDIR=$(cd $DIR && cd $(dirname -- "$SYM") && pwd)
done
cd "${BASEDIR}/.."

if [[ "$#" != "1" ]]; then
  echo "Usage: ${0} cellar-<environment>"
  exit 1
elif [[ ${1} == "cellar-prod" ]]; then
  BUCKET="cellar.kjetilvalle.com"
elif [[ ${1} == "cellar-test" ]]; then
  BUCKET="test.cellar.kjetilvalle.com"
elif [[ ${1} == "cellar-dev" ]]; then
  BUCKET="dev.cellar.kjetilvalle.com"
else
  echo "Environment not recognized: '$1'."
  exit 1
fi

./scripts/build.sh

s3cmd --delete-removed --config=./.s3cfg sync dist/ s3://${BUCKET}
