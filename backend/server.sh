#!/usr/bin/env bash
set -e

export FLASK_APP=api.py
export FLASK_DEBUG=1
flask run --host '0.0.0.0' --port 9000
