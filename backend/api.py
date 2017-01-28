import jwt
import os

from functools import wraps
from flask import Flask, request, jsonify, _app_ctx_stack
from flask_cors import cross_origin

from auth import requires_auth

app = Flask(__name__)


SERVER_DIR = os.path.dirname(os.path.realpath(__file__))
FILE_PATH = SERVER_DIR+"/data/beers.json"

def load():
    try:
        with open(FILE_PATH, "r") as f:
            return "".join(f.readlines())
    except IOError:
        return "[]"

def store(data):
    with open(FILE_PATH, "w") as f:
        f.write(data)
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
    if request.method == 'POST':
        data = request.get_json()
        if data is None:
            return bad_request()
        store(str(data))

    return load()
