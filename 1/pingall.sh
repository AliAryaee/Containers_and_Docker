#!/bin/bash
set -e

NAMESPACES=(node1 node2 node3 node4 router)
PING_CMD="./ping.sh"

for src in "${NAMESPACES[@]}"; do
  for dst in "${NAMESPACES[@]}"; do
    [[ "$src" == "$dst" ]] && continue
    if $PING_CMD "$src" "$dst" &>/dev/null; then
      status="OK"
    else
      status="FAIL"
    fi
    printf "%-6s ->  %-6s : %s\n" "$src" "$dst" "$status"
  done
done


