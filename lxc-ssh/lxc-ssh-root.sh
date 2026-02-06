#!/bin/bash
set -e

# Root SSH setup script (safe, preserves existing keys)

# Kontrollera att SSH public key skickas med
if [ -z "$1" ]; then
  echo "❌ No SSH public key provided"
  echo "Usage: $0 \"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA…\""
  exit 1
fi

PUBKEY="$1"

# Installera sudo och OpenSSH server om de inte finns
if ! dpkg -l | grep -qw openssh-server; then
    echo "🔹 Installing OpenSSH server..."
    apt update
    apt install -y openssh-server
fi

# Skapa .ssh-mapp för root
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Lägg till SSH-nyckeln om den inte redan finns
grep -qxF "$PUBKEY" /root/.ssh/authorized_keys 2>/dev/null || echo "$PUBKEY" >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Starta om SSH-tjänsten
systemctl enable ssh
systemctl restart ssh

# Visa resultat
echo "✅ Done: root SSH key installed"
echo "🖥 Hostname: $(hostname)"
IP=$(hostname -I | awk '{print $1}')
echo "🌐 IP: $IP"
echo "ℹ Root SSH login is enabled (key-based)"
