#!/usr/bin/env bash

# Bash script for running `elm make` every time a file is changed.
# Requires `inotifytools` or `fswatch` to be installed.

DEBUG=false
WATCH=false

function print_help() {
  echo "Usage: $0 [--debug] [--watch] [--help]"
  echo
  echo "  --debug     Build Elm app with debug activated"
  echo "  --watch     Rebuild application on changes"
  echo "  --help      Prints this message"
}

# idiomatic parameter and option handling in sh
while test $# -gt 0
do
    case "$1" in
        --debug) 
          DEBUG=true
          ;;
        --watch) 
          WATCH=true
          ;;
        --help)
          print_help
          exit 0
          ;;
        --*) 
          echo "Unexpected option: $1"
          echo
          print_help
          exit 1
          ;;
        *) 
          echo "Unexpected argument: $1"
          echo
          print_help
          exit 1
          ;;
    esac
    shift
done

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
    fswatch ./src ./static | (while read; do build; done)
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
  if ${DEBUG} ; then
    elm make src/Main.elm --output dist/app.js --debug --warn
  else
    elm make src/Main.elm --output dist/app.js --warn
  fi
  echo -e "Done.\n"
}


## Main

build

if ${WATCH} ; then
  watch_build
fi
