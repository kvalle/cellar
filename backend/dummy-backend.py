#!/usr/bin/python
# encoding: utf-8

from BaseHTTPServer import BaseHTTPRequestHandler,HTTPServer
import os

SERVER_DIR = os.path.dirname(os.path.realpath(__file__))
FILE_PATH = SERVER_DIR+"/data/beers.json"
PORT_NUMBER = 9000

def load():
	with open(FILE_PATH, "r") as f:
		return "".join(f.readlines())

def store(data):
	with open(FILE_PATH, "w") as f:
		f.write(data)
		f.flush()

class dummyHandler(BaseHTTPRequestHandler):
	
	def do_OPTIONS(self):
		self.send_response(200)
		self.send_header('Access-Control-Allow-Methods','*')
		self.send_header('Access-Control-Allow-Origin', '*')
		self.end_headers()
		self.wfile.write("")

	def do_GET(self):
		self.send_response(200)
		self.send_header('Content-type','application/json; charset=utf-8')
		self.send_header('Access-Control-Allow-Origin', '*')
		self.end_headers()
		self.wfile.write(load())

	def do_POST(self):
		global data
		content_len = int(self.headers.getheader('content-length', 0))
		store(self.rfile.read(content_len))
		self.send_response(200)
		self.send_header('Access-Control-Allow-Origin', '*')
		self.end_headers()

try:
	server = HTTPServer(('', PORT_NUMBER), dummyHandler)
	print 'Started httpserver on port ' , PORT_NUMBER

	server.serve_forever()

except KeyboardInterrupt:
	print 'shutting down'
	server.socket.close()
