#!/bin/bash
# Node Full System Monitor – CPU, RAM, Disk, Network, GPU, Motherboard

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
CPU_MODEL=$(lscpu | grep "Model name" | awk -F: '{print $2}' | sed 's/^[ \t]*//')
CPU_CORES=$(nproc)
CPU_FREQ=$(lscpu | grep "MHz" | awk -F: '{print $2}' | sed 's/^[ \t]*//')
CPU_FLAGS=$(lscpu | grep "Flags" | awk -F: '{print $2}')
echo "CPU:       $CPU_MODEL"
echo "Cores:     $CPU_CORES"
echo "Frequency: ${CPU_FREQ} MHz"
echo "Flags:     $CPU_FLAGS"
echo "-------------------------------"

# RAM info
TOTAL_RAM=$(free -h | awk '/^Mem:/ {print $2}')
USED_RAM=$(free -h | awk '/^Mem:/ {print $3}')
FREE_RAM=$(free -h | awk '/^Mem:/ {print $4}')
echo "RAM Total: $TOTAL_RAM | Used: $USED_RAM | Free: $FREE_RAM"
echo "-------------------------------"

# Swap info
TOTAL_SWAP=$(free -h | awk '/^Swap:/ {print $2}')
USED_SWAP=$(free -h | awk '/^Swap:/ {print $3}')
FREE_SWAP=$(free -h | awk '/^Swap:/ {print $4}')
echo "Swap Total: $TOTAL_SWAP | Used: $USED_SWAP | Free: $FREE_SWAP"
echo "-------------------------------"

# Disk info
df -h --total | grep total | awk '{print "Disk Total: "$2" | Used: "$3" | Free: "$4}'
echo "-------------------------------"

# GPU info
if command -v lspci &>/dev/null; then
    GPU_INFO=$(lspci | grep -E "VGA|3D")
    echo "GPU Info:"
    echo "$GPU_INFO"
else
    echo "GPU Info: Not available"
fi
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

# Network interfaces
echo "Network interfaces:"
for IFACE in $(ls /sys/class/net | grep -v lo); do
    MAC=$(cat /sys/class/net/$IFACE/address)
    IP_ADDR=$(ip -4 addr show $IFACE | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    echo " $IFACE | MAC: $MAC | IP: ${IP_ADDR:-N/A}"
done
echo "==============================="

# Optional: top 5 CPU processes
echo "Top 5 CPU processes:"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
echo "==============================="
