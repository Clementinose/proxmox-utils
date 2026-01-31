#!/bin/bash
set -e

# Root SSH setup script
# Author: Clementinose
# Purpose: Add a public SSH key to root's authorized_keys (safe, preserves existing keys)

if [ -z "$1" ]; then
  echo "❌ No SSH public key provided"
  echo "Usage: ./init-proxmox-root.sh \"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA…\""
  exit 1
fi

PUBKEY="$1"

# Ensure SSH server is installed
echo "🔹 Installing OpenSSH server if missing..."
apt update
apt install -y openssh-server

# Create .ssh folder for root if it doesn't exist
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Add the key if it's not already present
grep -qxF "$PUBKEY" /root/.ssh/authorized_keys 2>/dev/null || echo "$PUBKEY" >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Enable and restart SSH service
systemctl enable ssh
systemctl restart ssh

# Confirmation output
echo "✅ Done: root now has SSH access via the provided key"
echo "🖥 Hostname: $(hostname)"
IP=$(hostname -I | awk '{print $1}')
echo "🌐 IP: $IP"
