import os
import json
from functools import wraps
import time

import jwt
from flask import Flask, request, jsonify, _app_ctx_stack, Response
from flask_cors import cross_origin

from auth import requires_auth

app = Flask(__name__)


SERVER_DIR = os.path.dirname(os.path.realpath(__file__))
FILE_PATH = SERVER_DIR+"/data/beers.json"

def load():
    try:
        print "Loading from %s" % FILE_PATH
        with open(FILE_PATH, "r") as f:
            return "".join(f.readlines())
    except IOError:
        return "[]"

def store(string):
    with open(FILE_PATH, "w") as f:
        f.write(string)
        f.flush()

def bad_request():
    resp = jsonify({'code': 'bad_request', 
                    'description': 'expected json'})
    resp.status_code = 400
    return resp


@app.route("/api/beers", methods=['GET', 'POST'])
@cross_origin(headers=['Content-Type', 'Authorization'])
@requires_auth
def beers():
    print "Got request."
    if request.method == 'POST':
        print "It's a POST!"
        data = request.get_json()
        if data is None:
            return bad_request()
        store(json.dumps(data))
        time.sleep(2)

    print "Returning."
    return Response(response=load(), status=200, mimetype="application/json")
