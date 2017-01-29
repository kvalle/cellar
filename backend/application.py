#!/usr/bin/env python

import os
import os.path
import json
from functools import wraps
import time

import jwt
from flask import Flask, request, jsonify, _app_ctx_stack, Response
from flask_cors import cross_origin

from auth import requires_auth

application = Flask(__name__)


SERVER_DIR = os.path.dirname(os.path.realpath(__file__))
FILE_PATH = SERVER_DIR+"/data/beers.json"

def load():
    try:
        with open(FILE_PATH, "r") as f:
            return "".join(f.readlines())
    except IOError:
        return "[]"

def store(string):
    if not os.path.isdir(SERVER_DIR+"/data"):
        os.makedirs(SERVER_DIR+"/data")

    with open(FILE_PATH, "w") as f:
        f.write(string)
        f.flush()

def bad_request():
    resp = jsonify({'code': 'bad_request', 
                    'description': 'expected json'})
    resp.status_code = 400
    return resp


@application.route("/ping", methods=['GET'])
def ping():
    return "pong"


@application.route("/api/beers", methods=['GET', 'POST'])
@cross_origin(headers=['Content-Type', 'Authorization'])
@requires_auth
def beers():
    if request.method == 'POST':
        data = request.get_json()
        if data is None:
            return bad_request()
        store(json.dumps(data))
        time.sleep(2)

    return Response(response=load(), status=200, mimetype="application/json")


if __name__ == "__main__":
    application.debug = True
    application.run(host="0.0.0.0", port=9000, threaded=True)
