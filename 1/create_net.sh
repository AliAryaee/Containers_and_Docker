#!/bin/bash
set -e

echo "[*] Cleaning up old topology..."
for ns in node1 node2 node3 node4 router; do
  ip netns list | grep -qw "$ns" && ip netns delete "$ns"
done
for br in br1 br2; do
  ip link show "$br" &>/dev/null && {
    ip link set dev "$br" down
    ip link delete "$br" type bridge
  }
done
for iface in v1-br1 v2-br1 v3-br2 v4-br2 r1-br1 r1-br2; do
  ip link show "$iface" &>/dev/null && ip link delete "$iface"
done

echo "[*] Creating network namespaces..."
for ns in node1 node2 node3 node4 router; do
  echo "   - $ns"
  ip netns add "$ns"
done

echo "[*] Creating bridges..."
for br in br1 br2; do
  echo "   - $br"
  ip link add name "$br" type bridge
  ip link set dev "$br" up
done

echo "[*] Creating veth pairs for hosts..."
ip link add v1      type veth peer name v1-br1
ip link add v2      type veth peer name v2-br1
ip link add v3      type veth peer name v3-br2
ip link add v4      type veth peer name v4-br2

echo "[*] Creating veth pairs for router..."
ip link add r1-br1  type veth peer name r1-int1
ip link add r1-br2  type veth peer name r1-int2

echo "[*] Attaching veth ends to namespaces..."
ip link set v1      netns node1
ip link set v2      netns node2
ip link set v3      netns node3
ip link set v4      netns node4
ip link set r1-int1 netns router
ip link set r1-int2 netns router

echo "[*] Connecting veth ends to bridges..."
ip link set v1-br1  master br1
ip link set v2-br1  master br1
ip link set v3-br2  master br2
ip link set v4-br2  master br2
ip link set r1-br1  master br1
ip link set r1-br2  master br2

echo "[*] Bringing up bridge-side interfaces..."
for iface in br1 br2 v1-br1 v2-br1 v3-br2 v4-br2 r1-br1 r1-br2; do
  ip link set dev "$iface" up
done

echo "[*] Bringing up loopback and veth inside namespaces..."
for ns in node1 node2 node3 node4 router; do
  ip netns exec "$ns" ip link set lo up
done
ip netns exec node1  ip link set v1      up
ip netns exec node2  ip link set v2      up
ip netns exec node3  ip link set v3      up
ip netns exec node4  ip link set v4      up
ip netns exec router ip link set r1-int1 up
ip netns exec router ip link set r1-int2 up

echo "[*] Assigning IP addresses..."
ip netns exec node1  ip addr add 172.0.0.2/24  dev v1
ip netns exec node2  ip addr add 172.0.0.3/24  dev v2
ip netns exec node3  ip addr add 10.10.1.2/24 dev v3
ip netns exec node4  ip addr add 10.10.1.3/24 dev v4
ip netns exec router ip addr add 172.0.0.1/24  dev r1-int1
ip netns exec router ip addr add 10.10.1.1/24 dev r1-int2

echo "[*] Enabling IP forwarding on router..."
ip netns exec router sysctl -qw net.ipv4.ip_forward=1

echo "[*] Setting default routes on hosts..."
ip netns exec node1  ip route add default via 172.0.0.1
ip netns exec node2  ip route add default via 172.0.0.1
ip netns exec node3  ip route add default via 10.10.1.1
ip netns exec node4  ip route add default via 10.10.1.1

echo ">> Network created."


