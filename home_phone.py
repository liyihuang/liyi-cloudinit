from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs

# Use a dictionary to store URI and corresponding content
uri_content_map = {}

class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        # Parse the requested URI
        parsed_path = urlparse(self.path)
        uri = parsed_path.path

        # Check if the URI is in the dictionary
        if uri in uri_content_map:
            # Get the stored content
            content = uri_content_map[uri]
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(content.encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b'404 Not Found')

    def do_POST(self):
        # Parse the requested URI and content
        parsed_path = urlparse(self.path)
        uri = parsed_path.path
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length).decode('utf-8')

        # Store the content
        uri_content_map[uri] = post_data

        # Return a successful response
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'Content stored successfully')

def run(server_class=HTTPServer, handler_class=SimpleHTTPRequestHandler, port=8000):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print(f'Starting httpd on port {port}...')
    httpd.serve_forever()

if __name__ == '__main__':
    run()
