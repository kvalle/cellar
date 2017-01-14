#!/usr/bin/python
# encoding: utf-8

from BaseHTTPServer import BaseHTTPRequestHandler,HTTPServer

PORT_NUMBER = 9000

dummy_response = """

[{
	"name": "Nøgne IPA",
	"style": "IPA" ,
	"year": 2017,
	"count": 3
}, {
	"name": "Nøgne Imperial Stout",
	"style": "Imperial Stout" ,
	"year": 2016,
	"count": 1
}, {
	"name": "Oscar Blues Ten FIDY",
	"style": "Imperial Stout" ,
	"year": 2012,
	"count": 2
}, {
	"name": "AleSmith Speedway",
	"style": "Imperial Stout" ,
	"year": 2012,
	"count": 1
}, {
	"name": "AleSmith Speedway",
	"style": "Imperial Stout" ,
	"year": 2013,
	"count": 1
}, {
	"name": "Cervisiam Jungle Juice",
	"style": "IPA",
	"year": 2017,
	"count": 1
}]

"""

class dummyHandler(BaseHTTPRequestHandler):
	
	def do_OPTIONS(self):
		self.send_response(200)
		self.send_header('Access-Control-Allow-Methods','*')
		self.send_header('Access-Control-Allow-Origin', '*')
		self.end_headers()
		self.wfile.write("")
		return

	def do_GET(self):
		self.send_response(200)
		self.send_header('Content-type','application/json; charset=utf-8')
		self.send_header('Access-Control-Allow-Origin', '*')
		self.end_headers()
		self.wfile.write(dummy_response)
		return

try:
	server = HTTPServer(('', PORT_NUMBER), dummyHandler)
	print 'Started httpserver on port ' , PORT_NUMBER

	server.serve_forever()

except KeyboardInterrupt:
	print 'shutting down'
	server.socket.close()
