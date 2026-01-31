#!/bin/bash
# Script för att visa CPU och systemtemperatur på noden

set -e
clear
echo "🌡️ Proxmox Node Temperature Monitor"
echo "==============================="

HOSTNAME=$(hostname)
IP=$(hostname -I | awk '{print $1}')

echo "🖥️ Hostname: $HOSTNAME"
echo "🌐 IP: $IP"
echo ""

TEMP_SOURCE=""
CPU_TEMP=""

# 1️⃣ lm-sensors
if command -v sensors &>/dev/null; then
    CPU_TEMP=$(sensors | grep -i 'Core 0' | awk '{print $3}' | tr -d '+°C')
    if [[ -n "$CPU_TEMP" ]]; then
        TEMP_SOURCE="lm-sensors"
    fi
fi

# 2️⃣ /sys/class/thermal
if [ -z "$CPU_TEMP" ] && [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    CPU_TEMP=$(awk '{printf "%.1f", $1/1000}' /sys/class/thermal/thermal_zone*/temp | head -n1)
    TEMP_SOURCE="/sys/class/thermal"
fi

if [ -n "$CPU_TEMP" ]; then
    echo "🌡️ CPU Temperature: $CPU_TEMP °C"
    echo "🔎 Källa: $TEMP_SOURCE"
else
    echo "🌡️ CPU Temperature: Value cannot be found"
fi

echo "==============================="
