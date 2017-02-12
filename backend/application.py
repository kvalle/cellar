#!/usr/bin/env python

import os
import os.path
import json
from functools import wraps
import time
import sys

import jwt
from flask import Flask, request, jsonify, _app_ctx_stack, Response
from flask_cors import cross_origin

import data
from auth import requires_auth
import config


application = Flask(__name__)


def bad_request():
    resp = jsonify({'code': 'bad_request', 
                    'description': 'expected json'})
    resp.status_code = 400
    return resp


@application.route("/ping", methods=['GET'])
def ping():
    return "pong"


@application.route("/beers", methods=['GET', 'POST'])
@cross_origin(headers=['Content-Type', 'Authorization'])
@requires_auth
def beers():
    user_id = _app_ctx_stack.top.current_user["sub"]

    if request.method == 'POST':
        beers = request.get_json()
        if beers is None:
            return bad_request()
        data.store(user_id, json.dumps(beers))
        time.sleep(2)

    return Response(response=data.load(user_id), status=200, mimetype="application/json")


if __name__ == "__main__":
    if config.environment != "dev":
        print "Current config is for '%s', not 'dev'. Aborting." % config.environment
        sys.exit(1)
    application.debug = True
    application.run(host="0.0.0.0", port=9000, threaded=True)
