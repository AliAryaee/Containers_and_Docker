
# HTTP Server with Docker

## Building and Running the Docker Image

1. Build the Docker image:
   ```bash
   sudo docker build -t http_server_image .
   ```

2. Run the container:
   ```bash
   sudo docker run -d -p 8000:8000 --name http_server_container http_server_image
   ```
   The server will be available at `http://localhost:8000`.

   Upon running the container, you should see output indicating that the server has started successfully, similar to:
   ```
   Server started...
   ```

   The server will now listen on `0.0.0.0:8000` for requests.

## Verifying the Server

After starting the server (either locally or via Docker), you can verify its functionality with the following commands:

1. **Retrieve the initial status**:
   ```bash
   curl http://localhost:8000/api/v1/status
   ```
   Expected output:
   ```json
   {"status":"OK"}
   ```

2. **Update the status**:
   ```bash
   curl -X POST -H "Content-Type: application/json" -d '{"status": "not OK"}' http://localhost:8000/api/v1/status
   ```
   Expected output:
   ```json
   {"status":"not OK"}
   ```

3. **Retrieve the updated status**:
   ```bash
   curl http://localhost:8000/api/v1/status
   ```
   Expected output:
   ```json
   {"status":"not OK"}
   ```

4. **Test invalid data** (missing 'status' field or invalid JSON):
   ```bash
   curl -X POST -H "Content-Type: application/json" -d '{}' http://localhost:8000/api/v1/status
   ```
   Expected output:
   ```json
   {"error": "Missing 'status' key"}
   ```

5. **Test invalid JSON**:
   ```bash
   curl -X POST -H "Content-Type: application/json" -d '{"status":}' http://localhost:8000/api/v1/status
   ```
   Expected output:
   ```json
   {"error": "Invalid JSON"}
   ```

6. **Test GET request to invalid path (`/api/v1/other`)**:
   ```bash
   curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/api/v1/other
   ```
   Expected output:
   ```bash
   404
   ```

7. **Test POST request to invalid path (`/api/v1/other`)**:
   ```bash
   curl -X POST -H "Content-Type: application/json" -d '{"status":"not OK"}' http://localhost:8000/api/v1/other
   ```
   Expected output:
   ```json
   {"error": "Not Found"}
   ```

8. **Test GET request to a completely wrong path (`/wrong/path`)**:
   ```bash
   curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/wrong/path
   ```
   Expected output:
   ```bash
   404
   ```

9. **Test POST request to a completely wrong path (`/wrong/path`)**:
   ```bash
   curl -X POST -H "Content-Type: application/json" -d '{"status":"not OK"}' http://localhost:8000/wrong/path
   ```
   Expected output:
   ```json
   {"error": "Not Found"}
   ```

## Using `test.sh`

The `test.sh` script automates the process of testing the server by sending various GET and POST requests to the server and checking the responses. It tests the following scenarios:

1. **Initial GET request**: Verifies the server's default status (`"OK"`).
2. **POST request to change status**: Changes the status to `"not OK"`.
3. **GET request after POST**: Confirms that the status is `"not OK"`.
4. **POST request to change status back to `"OK"`**: Tests status toggling.
5. **GET request after second POST**: Verifies the status has toggled back to `"OK"`.
6. **POST request with invalid data**: Tests for missing `'status'` field.
7. **POST request with invalid JSON**: Tests for malformed JSON.
8. **GET and POST requests to invalid paths**: Tests that invalid paths return `404` and the correct error message.

To run the test script, simply execute:

```bash
sudo bash ./test.sh
```

This will run all the tests and print the results to the terminal.

---

By following these instructions, you can easily verify that the HTTP server is working as expected, handle edge cases, and ensure the server behaves correctly for valid and invalid requests.

