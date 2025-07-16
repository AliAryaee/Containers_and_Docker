#!/bin/bash

echo "Testing GET request (initial):"
curl -s http://localhost:8000/api/v1/status
echo -e "\n"

echo "Testing POST request to change status:"
curl -s -X POST -d '{"status":"not OK"}' -H "Content-Type: application/json" http://localhost:8000/api/v1/status
echo -e "\n"

echo "Testing GET request (after POST, status should be 'not OK'):"
curl -s http://localhost:8000/api/v1/status
echo -e "\n"

echo "Testing POST request to change status back to 'OK':"
curl -s -X POST -d '{"status":"OK"}' -H "Content-Type: application/json" http://localhost:8000/api/v1/status
echo -e "\n"

echo "Testing GET request (after second POST, status should be 'OK'):"
curl -s http://localhost:8000/api/v1/status
echo -e "\n"

echo "Testing POST request with invalid data (missing 'status' field):"
curl -s -X POST -d '{}' -H "Content-Type: application/json" http://localhost:8000/api/v1/status
echo -e "\n"

echo "Testing POST request with invalid JSON:"
curl -s -X POST -d '{"status":}' -H "Content-Type: application/json" http://localhost:8000/api/v1/status
echo -e "\n"

echo "Testing GET request to invalid path (/api/v1/other):"
curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/api/v1/other
echo -e "\n"

echo "Testing POST request to invalid path (/api/v1/other):"
curl -s -X POST -d '{"status":"not OK"}' -H "Content-Type: application/json" http://localhost:8000/api/v1/other
echo -e "\n"

echo "Testing GET request to completely wrong path (/wrong/path):"
curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/wrong/path
echo -e "\n"

echo "Testing POST request to completely wrong path (/wrong/path):"
curl -s -X POST -d '{"status":"not OK"}' -H "Content-Type: application/json" http://localhost:8000/wrong/path
echo -e "\n"

