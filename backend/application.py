#!/usr/bin/env python

import json
import time
import sys

import jwt
from flask import Flask, request, jsonify, _app_ctx_stack, Response
from flask_cors import cross_origin

import app.main
import app.config

application = app.main.application


if __name__ == "__main__":
    if app.config.environment != "dev":
        print "Current config is for '%s', not 'dev'. Aborting." % app.config.environment
        sys.exit(1)
    application.debug = True
    application.run(host="0.0.0.0", port=9000, threaded=True)
