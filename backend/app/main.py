#!/usr/bin/env python

import json
import time
import sys

import jwt
from flask import Flask, request, jsonify, _app_ctx_stack, Response
from flask_cors import cross_origin

import data
from auth import requires_auth
import config


application = Flask("Cellar Index")


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
