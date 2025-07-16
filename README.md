
# Containers and Docker - Assignment 2

## Introduction
This repository contains the solutions for the Containers and Docker assignment. It includes implementations for container networking, container runtime creation, and Dockerized HTTP server.

## Table of Contents
1. [Problem 1: Container Networking](#problem-1-container-networking)
2. [Problem 2: Container Runtime](#problem-2-container-runtime)
3. [Problem 3: Docker](#problem-3-docker)
4. [File Structure](#file-structure)

## Problem 1: Container Networking
In this problem, you are asked to create a network topology with network namespaces and a router, as described in the assignment.

### Requirements:
- Every node should be able to ping every other node and the router.
- Nodes in the 172.0.0.0/24 subnet should communicate with nodes in the 10.10.1.0/24 subnet only via the router.
- A bash script is required to create the topology and initiate pinging between nodes.

### Deliverables:
- `1/create_net.sh`: Script to set up the network topology.
- `1/ping.sh`: Script to ping between nodes.
- `1/pingall.sh`: Script to ping all nodes.
- `1/Q1.md`: Explanation for network setup.
- `1/Q2.md`: Explanation for packet routing when the router is deleted.

### Problem Explanation:
The problem also requires an explanation on how to route packets between subnets if the router is deleted, and how to manage namespaces across different physical or virtual machines.

## Problem 2: Container Runtime
This problem requires you to implement a container runtime using any programming language of your choice (Python, Bash, Go, etc.).

### Requirements:
- The container runtime CLI must create new namespaces (`net`, `mnt`, `pid`, `uts`).
- The container should have its own separate filesystem, and the root of the container should be a directory containing an Ubuntu 20.04 filesystem.
- The CLI should accept an optional memory limit parameter in megabytes.

### Deliverables:
- `2/container.sh`: Script for creating containers.
- `2/test_memory.sh`: Optional script for testing memory limits of the container.
- `2/README.md`: Instructions for using the container runtime CLI.

## Problem 3: Docker
This problem focuses on Docker and involves writing a simple HTTP server and Dockerizing it.

### Requirements:
- The server must handle GET and POST requests to the `/api/v1/status` endpoint.
- The server should respond with JSON data:
  - GET requests return `{ "status": "OK" }`.
  - POST requests modify the status and return the updated status in the response.

### Deliverables:
- `3/server.py`: Code for the HTTP server.
- `3/Dockerfile`: Dockerfile to build the Docker image for the server.
- `3/test.sh`: Test script for the HTTP server.

## File Structure
```
.
├── 1
│   ├── create_net.sh        # Script to create the network topology
│   ├── pingall.sh           # Script to ping all nodes
│   ├── ping.sh              # Script to ping between two nodes
│   ├── Q1.md                # Explanation for network setup
│   ├── Q2.md                # Explanation for packet routing
│   └── README.md            # README for Problem 1
├── 2
│   ├── container.sh         # Script for creating the container
│   ├── README.md            # README for Problem 2
│   └── test_memory.sh       # Memory testing script for containers
├── 3
│   ├── Dockerfile           # Dockerfile to build the HTTP server image
│   ├── README.md            # README for Problem 3
│   ├── server.py            # Code for the HTTP server
│   └── test.sh              # Test script for the HTTP server
└── README.md                # Main README for the repository
```

## How to Run

### Problem 1:
1. Navigate to the `1` directory.
2. Run `./create_net.sh` to create the network topology.
3. Run `./ping.sh <node1> <node2>` to ping between nodes.
4. Run `./pingall.sh` to ping all nodes.

### Problem 2:
1. Navigate to the `2` directory.
2. Run `./container.sh <hostname>` to create a container.
3. Optionally, use `./test_memory.sh` to test the memory limit of the container.

### Problem 3:
1. Navigate to the `3` directory.
2. Build the Docker image using:
   ```bash
   docker build -t <image_name> .
   ```
3. Run the Docker container using:
   ```bash
   docker run -p 8000:8000 <image_name>
   ```

## Conclusion
This repository provides the solutions to the Containers and Docker assignment. It covers essential DevOps concepts including container networking, container runtime creation, and Docker-based applications.

Feel free to explore the individual directories for each problem and execute the scripts for testing.

