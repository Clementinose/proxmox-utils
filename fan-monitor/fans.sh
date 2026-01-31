#!/bin/bash
# Script för att visa fläkthastigheter

set -e
clear
echo "💨 Proxmox Node Fan Monitor"
echo "==============================="

HOSTNAME=$(hostname)
IP=$(hostname -I | awk '{print $1}')

echo "🖥️ Hostname: $HOSTNAME"
echo "🌐 IP: $IP"
echo ""

FAN_SOURCE=""
FAN_SPEED=""

# 1️⃣ lm-sensors
if command -v sensors &>/dev/null; then
    FAN_SPEED=$(sensors | grep -i 'fan' | awk '{print $2}' | tr -d 'RPM')
    if [[ -n "$FAN_SPEED" ]]; then
        FAN_SOURCE="lm-sensors"
    fi
fi

# 2️⃣ /sys/class/hwmon
if [ -z "$FAN_SPEED" ] && ls /sys/class/hwmon/hwmon*/fan*_input &>/dev/null; then
    FAN_SPEED=$(cat /sys/class/hwmon/hwmon*/fan*_input 2>/dev/null)
    FAN_SOURCE="/sys/class/hwmon"
fi

if [ -n "$FAN_SPEED" ]; then
    echo "💨 Fan Speed(s): $FAN_SPEED RPM"
    echo "🔎 Källa: $FAN_SOURCE"
else
    echo "💨 Fan Speed(s): Value cannot be found"
fi

echo "==============================="
