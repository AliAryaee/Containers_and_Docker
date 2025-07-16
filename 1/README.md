
# Network Namespace Topology Project

This project involves setting up a Linux network topology using network namespaces and bridges. The goal is to create a functional network that simulates different nodes connected through a router, as well as tools to test connectivity between nodes using ping.

## Overview

### Scripts:
1. **create_net.sh** - Sets up a network topology with 4 nodes and a router using Linux network namespaces and bridges.
2. **ping.sh** - Pings a target node or IP from a given source node.
3. **pingall.sh** - Pings all nodes in the network and prints the status of each ping.

### Network Topology:
The topology includes:
- 4 nodes (`node1`, `node2`, `node3`, `node4`)
- A router that connects two different subnets (`172.0.0.0/24` and `10.10.1.0/24`)
- Each node and the router are in separate network namespaces.
- Bridges (`br1`, `br2`) connect the virtual Ethernet pairs (`v1-br1`, `v2-br1`, `v3-br2`, `v4-br2`) to the namespaces.

## How to Use the Code

### 1. **Setting Up the Network**

Run the `create_net.sh` script to create the network topology. The script will:
- Install necessary prerequisites (Open vSwitch).
- Set up network namespaces for `node1`, `node2`, `node3`, `node4`, and the `router`.
- Create two bridges (`br1`, `br2`), connect the virtual interfaces to the bridges, and configure the IP addresses.

To execute the script:

```bash
chmod +x create_net.sh
sudo ./create_net.sh
```

This will output the setup progress, indicating the success of each step.

### 2. **Pinging Nodes**

Use the `ping.sh` script to ping a node from another node. The script takes two arguments: the source node and the target node or IP.

To test connectivity between `node1` and the `router`:

```bash
chmod +x ping.sh
./ping.sh node1 router
```

This will ping the router from `node1` and print the result.

### 3. **Ping All Nodes**

The `pingall.sh` script tests connectivity between all nodes and the router. It runs the `ping.sh` script for each combination of source and destination nodes and prints the status.

To execute:

```bash
chmod +x pingall.sh
./pingall.sh
```

This will display the connectivity status between all nodes.

## Questions and Answers

### Question 1: Network Topology Without Router

In the network topology shown in **Figure 2**, the router is removed, and the network needs to route traffic between the two subnets (172.0.0.0/24 and 10.10.1.0/24). In this case, routing can be achieved using **proxy ARP** or **static routing** in the root namespace.

- **Proxy ARP**: The root namespace can configure a proxy ARP to forward traffic between the two subnets, allowing nodes in different subnets to communicate without the need for a router.
- **Static Routing**: Alternatively, static routes can be added in the root namespace to route traffic between the two subnets. This would involve using the `ip route add` command.

**Solution to Problem 1**: See the [Q1.md](Q1.md) file for a detailed explanation.

### Question 2: Network Namespace on Different Servers

If the namespaces are on different servers, the solution would involve setting up **bridges** or **tunnels** between the servers. The servers should be able to communicate over layer 2 (Ethernet), and the network namespaces on each server would need proper routing rules.

- **Bridges**: The virtual machines or physical servers can set up bridges between the namespaces to allow them to communicate as if they are on the same local network.
- **Tunnels (e.g., GRE, VXLAN)**: In cases where direct layer 2 communication is not possible, tunnels can be used to simulate a local network over a wider area network.

**Solution to Problem 2**: See the [Q2.md](Q2.md) file for a detailed explanation.

## Conclusion

This project demonstrates how to set up a network topology using Linux network namespaces and bridges. It also provides scripts for testing node connectivity and answers to theoretical questions about routing in different network setups.

For more details on the implementation, refer to the [Q1.md](Q1.md) and [Q2.md](Q2.md) files.

