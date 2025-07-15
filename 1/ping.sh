#!/bin/bash
set -e

if [ $# -ne 2 ]; then
  echo "Usage: $0 <source_ns> <target_ns_or_IP>"
  exit 1
fi

SRC="$1"
DST="$2"

ns_ip() {
  case "$1" in
    node1) echo 172.0.0.2 ;;
    node2) echo 172.0.0.3 ;;
    node3) echo 10.10.1.2 ;;
    node4) echo 10.10.1.3 ;;
    router) echo 172.0.0.1 ;;
    *) echo "$1" ;;
  esac
}

TARGET_IP=$(ns_ip "$DST")
ip netns exec "$SRC" ping -c1 -W1 "$TARGET_IP"

