#!/usr/bin/python
# encoding: utf-8

from BaseHTTPServer import BaseHTTPRequestHandler,HTTPServer

PORT_NUMBER = 9000

dummy_response = """

[{
	"name": "Nøgne IPA",
	"style": "IPA" }, 
{
	"name": "Nøgne Imperial Stout",
	"style": "Imperial Stout" }, 
{
	"name": "Cervisiam Jungle Juice",
	"style": "IPA" 
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
