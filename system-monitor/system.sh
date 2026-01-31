#!/bin/bash
# Node Full System Monitor – CPU, RAM, Disk, Network, GPU, Motherboard, Memory Channels

clear
echo "==============================="
echo "🖥️ Proxmox Node Full System Monitor"
echo "==============================="

# Hostname & IP
HOSTNAME=$(hostname)
IP=$(hostname -I | awk '{print $1}')
echo "Hostname: $HOSTNAME"
echo "IP:       $IP"
echo "==============================="

# CPU info
CPU_MODEL=$(lscpu | awk -F: '/Model name/ {print $2}' | xargs)
CPU_CORES=$(nproc)
CPU_FREQ=$(lscpu | awk -F: '/CPU MHz/ {print $2 " MHz"}' | xargs)
CPU_FLAGS=$(lscpu | awk -F: '/Flags/ {print $2}' | xargs)
CPU_SOCKETS=$(lscpu | awk -F: '/Socket/ {print $2}' | xargs)
echo "CPU:       $CPU_MODEL"
echo "Cores:     $CPU_CORES"
echo "Sockets:   $CPU_SOCKETS"
echo "Frequency: $CPU_FREQ"
echo "Flags:     $CPU_FLAGS"
echo "-------------------------------"

# RAM info
TOTAL_RAM=$(free -h | awk '/^Mem:/ {print $2}')
USED_RAM=$(free -h | awk '/^Mem:/ {print $3}')
FREE_RAM=$(free -h | awk '/^Mem:/ {print $4}')
RAM_CHANNELS=$(dmidecode -t memory 2>/dev/null | grep "Locator:" | wc -l)
echo "RAM Total: $TOTAL_RAM | Used: $USED_RAM | Free: $FREE_RAM"
echo "Memory Channels: $RAM_CHANNELS"
echo "-------------------------------"

# Swap info
TOTAL_SWAP=$(free -h | awk '/^Swap:/ {print $2}')
USED_SWAP=$(free -h | awk '/^Swap:/ {print $3}')
FREE_SWAP=$(free -h | awk '/^Swap:/ {print $4}')
echo "Swap Total: $TOTAL_SWAP | Used: $USED_SWAP | Free: $FREE_SWAP"
echo "-------------------------------"

# Disk info
df -h --total | awk '/total/ {print "Disk Total: "$2" | Used: "$3" | Free: "$4}'
echo "-------------------------------"

# GPU info
GPU_INFO=$(lspci 2>/dev/null | grep -E "VGA|3D" || echo "Not available")
echo "GPU Info: $GPU_INFO"
echo "-------------------------------"

# Motherboard & BIOS info
if [ -f /sys/class/dmi/id/board_name ]; then
    BOARD_NAME=$(cat /sys/class/dmi/id/board_name)
    BOARD_VENDOR=$(cat /sys/class/dmi/id/board_vendor)
    BIOS_VERSION=$(cat /sys/class/dmi/id/bios_version)
    echo "Motherboard: $BOARD_VENDOR $BOARD_NAME"
    echo "BIOS Version: $BIOS_VERSION"
else
    echo "Motherboard info: Not available"
fi
echo "-------------------------------"

# Network interfaces (filter virtual interfaces)
echo "Network interfaces:"
for IFACE in $(ls /sys/class/net | grep -Ev "lo|bonding_masters|veth|docker|br-"); do
    MAC=$(cat /sys/class/net/$IFACE/address)
    IPV4=$(ip -4 addr show $IFACE | awk '/inet / {print $2}' | cut -d/ -f1)
    IPV6=$(ip -6 addr show $IFACE | awk '/inet6 / {print $2}' | cut -d/ -f1)
    echo " $IFACE | MAC: $MAC | IPv4: ${IPV4:-N/A} | IPv6: ${IPV6:-N/A}"
done
echo "==============================="

# Optional: top 5 CPU processes
echo "Top 5 CPU processes:"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
echo "==============================="
