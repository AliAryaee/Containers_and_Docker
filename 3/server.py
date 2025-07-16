from http.server import BaseHTTPRequestHandler, HTTPServer
import json

class StatusHandler(BaseHTTPRequestHandler):
    current_status = "OK"

    def do_GET(self):
        if self.path != '/api/v1/status':
            self.send_response(404)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(bytes('{"error": "Not Found"}', "utf-8"))
            return
        
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        response = json.dumps({"status": self.current_status})
        self.wfile.write(response.encode())

    def do_POST(self):
        if self.path != '/api/v1/status':
            self.send_response(404)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(bytes('{"error": "Not Found"}', "utf-8"))
            return
        
        length = int(self.headers['Content-Length'])
        data = self.rfile.read(length)
        
        try:
            json_data = json.loads(data)
            if 'status' not in json_data:
                self.send_response(400)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                self.wfile.write(bytes('{"error": "Missing \'status\' key"}', "utf-8"))
                return
            
            if json_data['status'] == "not OK":
                StatusHandler.current_status = "not OK"
            else:
                StatusHandler.current_status = "OK"
            
            self.send_response(201)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            response = json.dumps({"status": StatusHandler.current_status})
            self.wfile.write(response.encode())
        
        except json.JSONDecodeError:
            self.send_response(400)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(bytes('{"error": "Invalid JSON"}', "utf-8"))
        except Exception as e:
            self.send_response(400)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(bytes(f'{{"error": "{str(e)}"}}', "utf-8"))

def run():
    server_address = ('0.0.0.0', 8000)
    httpd = HTTPServer(server_address, StatusHandler)
    print("Server started...")
    httpd.serve_forever()

if __name__ == '__main__':
    run()

