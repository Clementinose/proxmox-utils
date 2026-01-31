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

# Installera OpenSSH server om det inte finns
if ! dpkg -l | grep -qw openssh-server; then
    echo "🔹 Installing OpenSSH server..."
    apt update
    apt install -y openssh-server
fi

# Skapa .ssh-mapp för root om den inte finns
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Lägg till key om den inte redan finns
grep -qxF "$PUBKEY" /root/.ssh/authorized_keys 2>/dev/null || echo "$PUBKEY" >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Aktivera och starta om SSH-tjänsten
systemctl enable ssh
systemctl restart ssh

# Visa resultat
echo "✅ Done: root now has SSH access via the provided key"
echo "🖥 Hostname: $(hostname)"
IP=$(hostname -I | awk '{print $1}')
echo "🌐 IP: $IP"
