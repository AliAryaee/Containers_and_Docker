#!/bin/bash
set -euo pipefail

# Ensure running as root
if (( EUID != 0 )); then
  echo "ERROR: please run with sudo on the host" >&2
  exit 1
fi

# Usage
usage() {
  echo "Usage: sudo $0 [-r] [-l] [-e] <hostname> [memory_limit]" >&2
  echo "  -r        Remove the specified container or remove all containers if no hostname is provided" >&2
  echo "  -l        List all containers" >&2
  echo "  -e        Run the specified container" >&2
  echo "  memory_limit Memory limit for the container in MB" >&2
  exit 1
}

REMOVE=false
LIST=false
RUN=false
REMOVE_ALL=false
MEMORY_LIMIT=0

while getopts ":rle" opt; do
  case $opt in
    r) REMOVE=true ;;
    l) LIST=true ;;
    e) RUN=true ;;
    *) usage ;;
  esac
done
shift $((OPTIND -1))

# Set memory limit if provided
if [[ $# -gt 1 ]]; then
  MEMORY_LIMIT="$2"
fi

# Remove all containers
if $REMOVE && [[ $# -eq 0 ]]; then
  echo "[*] Removing all containers..."
  for CT in ./containers/*; do
    if [[ -d "$CT" ]]; then
      HOST=$(basename "$CT")
      echo "[*] Removing container '$HOST'..."
      umount -l "$CT/proc" 2>/dev/null || true
      umount -l "$CT/sys" 2>/dev/null || true
      umount -l "$CT/dev/pts" 2>/dev/null || true
      umount -l "$CT/dev" 2>/dev/null || true
      umount -l "$CT" 2>/dev/null || true
      rm -rf "$CT"
    fi
  done
  echo "[*] All containers have been removed."
  exit 0
fi

# Remove a specific container
if $REMOVE; then
  if [[ $# -ne 1 ]]; then
    usage
  fi
  HOST="$1"
  CT="./containers/$HOST"
 
  # Unmount and clean up
  echo "[*] Removing container '$HOST'..."
  umount -l "$CT/proc" 2>/dev/null || true
  umount -l "$CT/sys" 2>/dev/null || true
  umount -l "$CT/dev/pts" 2>/dev/null || true
  umount -l "$CT/dev" 2>/dev/null || true
  umount -l "$CT" 2>/dev/null || true
  rm -rf "$CT"
  echo "[*] Container '$HOST' has been removed."
  exit 0
fi

# List containers
if $LIST; then
  echo "[*] Listing all containers:"

  # Ensure the containers directory exists
  if [[ ! -d "./containers" ]]; then
    echo "[*] No containers found."
    exit 0
  fi

  CONTAINERS=$(ls ./containers/)

  if [[ -z "$CONTAINERS" ]]; then
    echo "[*] No containers found."
  else
    echo "$CONTAINERS"
  fi
  exit 0
fi

# Run container
if $RUN; then
  if [[ $# -ne 1 ]]; then
    usage
  fi
  HOST="$1"
  CT="./containers/$HOST"

  if [[ ! -d "$CT" ]]; then
    echo "ERROR: container '$HOST' does not exist." >&2
    exit 1
  fi

  # Apply memory limit if set
  if [[ "$MEMORY_LIMIT" -gt 0 ]]; then
    echo "[*] Setting memory limit for container '$HOST' to ${MEMORY_LIMIT}MB..."
    systemctl set-property "$HOST.service" MemoryMax="${MEMORY_LIMIT}M"
    systemctl set-property "$HOST.service" MemoryHigh="${MEMORY_LIMIT}M"
  fi

  echo "[*] Running container '$HOST'..."
  # Enter the container and run it in the appropriate namespaces
  unshare --fork --pid --uts --net --mount --mount-proc="${CT}/proc" bash -c "
    mount --make-rprivate /; \
    mkdir -p '${CT}/sys'; \
    mount -t sysfs sysfs '${CT}/sys'; \
    hostname '${HOST}'; \
    exec chroot '${CT}' /bin/bash --login
  "
  exit 0
fi

# Create container
if [[ $# -lt 1 ]]; then
  usage
fi

HOST="$1"

# Install debootstrap if not present
if ! command -v debootstrap &>/dev/null; then
  apt update
  apt install -y debootstrap
fi

BASE="./ubuntu-fs"
if [[ ! -d $BASE ]]; then
  debootstrap --arch=amd64 --variant=minbase --include=bash,coreutils,procps,iproute2 \
    focal "$BASE" http://archive.ubuntu.com/ubuntu
fi

CT="./containers/$HOST"
if [[ -e $CT ]]; then
  echo "ERROR: container '$HOST' already exists." >&2
  exit 1
fi
mkdir -p containers
cp -a "$BASE" "$CT"

# Create systemd service for the container
echo "[*] Creating systemd service for container '$HOST'..."

# Create a basic systemd service file
SERVICE_PATH="/etc/systemd/system/$HOST.service"

cat << EOF > "$SERVICE_PATH"
[Unit]
Description=Container $HOST
After=network.target

[Service]
ExecStart=/usr/bin/bash -c 'exec chroot $CT /bin/bash'
Restart=always
MemoryMax=${MEMORY_LIMIT}M
MemoryHigh=${MEMORY_LIMIT}M

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable the container service
systemctl daemon-reload
systemctl enable "$HOST.service"

# Mount filesystems for container
echo "[*] Mounting filesystems for container..."
mkdir -p "$CT"/{proc,sys,dev,dev/pts}
mount --bind "$CT" "$CT"
mount --bind /lib "$CT/lib"
mount --bind /lib64 "$CT/lib64" 2>/dev/null || true
mount --bind /usr/lib "$CT/usr/lib"
mount -t proc   proc  "$CT/proc"
mount -t sysfs  sysfs "$CT/sys"
mount --bind /dev     "$CT/dev"
mount --bind /dev/pts "$CT/dev/pts"

# Apply memory limit if set
if [[ "$MEMORY_LIMIT" -gt 0 ]]; then
  echo "[*] Setting memory limit for container '$HOST' to ${MEMORY_LIMIT}MB..."
  systemctl set-property "$HOST.service" MemoryMax="${MEMORY_LIMIT}M"
  systemctl set-property "$HOST.service" MemoryHigh="${MEMORY_LIMIT}M"
fi

# Enter isolated namespaces and chroot
echo "[*] Entering container '$HOST'. Type 'exit' to return to host."
unshare --fork --pid --uts --net --mount --mount-proc="${CT}/proc" bash -c "
  mount --make-rprivate /; \
  mkdir -p '${CT}/sys'; \
  mount -t sysfs sysfs '${CT}/sys'; \
  hostname '${HOST}'; \
  exec chroot '${CT}' /bin/bash --login
"

