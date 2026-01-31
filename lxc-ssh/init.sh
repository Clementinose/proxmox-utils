#!/bin/bash
set -e

USERNAME="clements"

# Kontrollera att SSH public key skickas med
if [ -z "$1" ]; then
  echo "❌ No SSH public key provided"
  echo "Usage: $0 \"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA…\""
  exit 1
fi

PUBKEY="$1"

# Installera sudo och OpenSSH server om de inte finns
if ! dpkg -l | grep -qw sudo; then
    echo "🔹 Installing sudo..."
    apt update
    apt install -y sudo
fi

if ! dpkg -l | grep -qw openssh-server; then
    echo "🔹 Installing OpenSSH server..."
    apt update
    apt install -y openssh-server
fi

# Skapa användare om den inte finns
if id "$USERNAME" &>/dev/null; then
    echo "ℹ User '$USERNAME' already exists"
else
    echo "🔹 Creating user '$USERNAME'..."
    useradd -m -s /bin/bash "$USERNAME"
fi

# Lägg till användaren i sudo-gruppen
usermod -aG sudo "$USERNAME"

# Skapa .ssh-mapp och authorized_keys
mkdir -p /home/$USERNAME/.ssh
chmod 700 /home/$USERNAME/.ssh
echo "$PUBKEY" > /home/$USERNAME/.ssh/authorized_keys
chmod 600 /home/$USERNAME/.ssh/authorized_keys
chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh

# Starta om SSH-tjänsten
systemctl enable ssh
systemctl restart ssh

# Visa resultat
echo "✅ Done: '$USERNAME' is admin + SSH key installed"
echo "🖥 Hostname: $(hostname)"
IP=$(hostname -I | awk '{print $1}')
echo "🌐 IP: $IP"
echo "ℹ Root login and password are still active, you can also SSH as root"
