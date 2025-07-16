
# Container Runtime CLI

This project is a simple container runtime CLI that allows the creation, management, and execution of containers. The CLI script uses namespaces (net, mnt, pid, and uts) to create isolated environments for each container, similar to how Docker works but with a simplified implementation.

### Requirements

- You must have `sudo` privileges to run the commands.
- The container runtime is written in Bash and relies on basic Linux utilities such as `debootstrap`, `unshare`, and `systemd` to function.

### Features

1. **Create a Container**: Creates a container with its own isolated filesystem, based on the Ubuntu 20.04 image.
2. **List Containers**: Lists all created containers.
3. **Remove Containers**: Removes a specified container or all containers.
4. **Run Containers**: Runs the container in an isolated namespace with a configurable memory limit.
5. **Memory Limit**: Optionally set a memory limit in MB for the container.

### Files Included

- `container.sh`: The main script for creating, running, listing, and removing containers.
- `test_memory.sh`: A script to check and display the memory limits set for all containers.

### Usage

The CLI script `container.sh` supports the following commands:

1. **List all containers**:
   ```bash
   sudo ./container.sh -l
   ```
   This will list all containers that have been created. If there are no containers, it will output "No containers found."

2. **Create a new container**:
   ```bash
   sudo ./container.sh <hostname> [memory_limit]
   ```
   - `<hostname>`: The name of the container to create.
   - `[memory_limit]`: (Optional) The memory limit for the container in MB. If no limit is specified, the container will not have any memory limit set.

   **Note**: After creating a container, it will **automatically run** and enter the container's shell.

3. **Remove a specific container**:
   ```bash
   sudo ./container.sh -r <hostname>
   ```
   - `<hostname>`: The name of the container to remove. This will unmount and delete the container's filesystem.

4. **Remove all containers**:
   ```bash
   sudo ./container.sh -r
   ```
   This will remove all containers that have been created.

5. **Run a container** (only after it has been created and exited):
   ```bash
   sudo ./container.sh -e <hostname>
   ```
   - `<hostname>`: The name of the container to run. This will execute the container with the specified name in an isolated namespace. **Use this command if you have exited the container and want to start it again**.

### Example

To create a container with the hostname `test_mem` and set a memory limit of 72 MB:

```bash
sudo ./container.sh test_mem 72
```

This will create a container named `test_mem` with a 72 MB memory limit and it will **automatically run**. After creation, you can **exit** the container, and to restart it, use:

```bash
sudo ./container.sh -e test_mem
```

To list all containers:

```bash
sudo ./container.sh -l
```

To remove a specific container:

```bash
sudo ./container.sh -r test_mem
```

To remove all containers:

```bash
sudo ./container.sh -r
```

### Memory Management

The memory limits are applied using `systemctl` by setting `MemoryMax` and `MemoryHigh` properties in the container's systemd service. This ensures that the container's memory usage is restricted to the specified limit.

### Systemd Service

When a container is created, a corresponding `systemd` service is generated to manage the container. This service is configured to:

- Start the container in isolated namespaces.
- Enforce memory limits if specified.
- Automatically restart the container if it stops.

### Troubleshooting

- If you encounter issues with systemd services, ensure that `systemd` is properly configured on your system and that the container service is enabled (`systemctl enable <hostname>.service`).
- Ensure that the `debootstrap` tool is installed for creating the container filesystem. If not, the script will automatically install it for you.

### Notes

- This project is a simple implementation for educational purposes and is not intended for production use.
- The memory limit feature is optional. If you do not provide a memory limit when creating a container, the container will run without any memory restrictions.

