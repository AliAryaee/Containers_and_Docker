#!/bin/bash
set -e

echo "[*] Checking memory limits for all current containers..."

# List all containers
CONTAINERS=$(ls ./containers/)

if [[ -z "$CONTAINERS" ]]; then
  echo "[*] No containers found."
  exit 0
fi

# Check memory limits for each container
for HOST in $CONTAINERS; do
  echo "[*] Checking memory limits for container '$HOST'..."
  systemctl show "$HOST.service" -p MemoryMax -p MemoryHigh
done

echo "[*] Memory limits checked for all containers."

