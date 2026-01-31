#!/bin/bash
set -e

USERNAME="clements"

if [ -z "$1" ]; then
  echo "❌ Ingen SSH public key angiven"
  echo "Usage: ./init-proxmox.sh \"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA…\""
  exit 1
fi

PUBKEY="$1"

# Installera sudo och openssh-server om det inte finns
apt update
apt install -y sudo openssh-server

# Skapa user och lägg till sudo
useradd -m -s /bin/bash "$USERNAME" 2>/dev/null || echo "User $USERNAME exists"
usermod -aG sudo "$USERNAME"

# Skapa .ssh-mapp och authorized_keys
mkdir -p /home/$USERNAME/.ssh
chmod 700 /home/$USERNAME/.ssh
echo "$PUBKEY" > /home/$USERNAME/.ssh/authorized_keys
chmod 600 /home/$USERNAME/.ssh/authorized_keys
chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh

# Starta om SSH
systemctl enable ssh
systemctl restart ssh

# Visa resultat
echo "✅ Klar: $USERNAME är admin + SSH-nyckel (root/lösenord är fortfarande aktivt)"
echo "🖥 Hostname: $(hostname)"
IP=$(hostname -I | awk '{print $1}')
echo "🌐 IP: $IP"
