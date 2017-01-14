#!/usr/bin/env bash

# Bash script for running `elm make` every time a file is changed.
# Requires `inotifytools` or `fswatch` to be installed.

function main() {
  build

  if [[ "$1" == "watch" ]]; then
    watch_build
  fi
}

function watch_build() {
  function log_test_run {
    msg="Prepared to run tests on new changes..."
    echo -e "\033[1;37m> $msg\033[0m"
  }

  if command -v inotifywait >/dev/null; then
    log_test_run
    while inotifywait -q -r -e modify . ; do
      build
    done
  fi

  if command -v fswatch >/dev/null; then
    log_test_run
    fswatch ./src | (while read; do build; done)
  fi
}

function build {
  echo "Cleaning /dist"
  mkdir -p dist
  rm -r dist/*
  cp -R static/* dist/
  echo "Running 'elm format'"
  elm format src/ --yes
  echo "Running 'elm make'"
  elm make src/Main.elm --output dist/app.js
  echo -e "Done.\n"
}

main "$@"
