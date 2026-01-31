#!/bin/bash
set -e

clear
echo "🔌 Proxmox Node Power Monitor"
echo "==============================="

HOSTNAME=$(hostname)
IP=$(hostname -I | awk '{print $1}')

echo "🖥️ Hostname: $HOSTNAME"
echo "🌐 IP: $IP"
echo ""

POWER_W=""
SOURCE=""

############################
# 1️⃣ IPMI (Dell / HP server)
############################
if command -v ipmitool &>/dev/null; then
    IPMI_W=$(ipmitool sdr 2>/dev/null | grep -i watt | awk '{print $NF}' | head -n1)
    if [[ "$IPMI_W" =~ ^[0-9]+$ ]]; then
        POWER_W="$IPMI_W"
        SOURCE="IPMI"
    fi
fi

##################################
# 2️⃣ Redfish (iDRAC / iLO / BMC)
##################################
if [ -z "$POWER_W" ] && [ -f /etc/redfish.env ]; then
    source /etc/redfish.env
    if command -v curl &>/dev/null && command -v jq &>/dev/null; then
        RF_W=$(curl -sk -u "$RF_USER:$RF_PASS" \
          "https://$RF_HOST/redfish/v1/Chassis/1/Power" \
          | jq -r '.PowerControl[0].PowerConsumedWatts')
        if [[ "$RF_W" =~ ^[0-9]+$ ]]; then
            POWER_W="$RF_W"
            SOURCE="Redfish"
        fi
    fi
fi

############################
# 3️⃣ RAPL (Intel CPU power)
############################
if [ -z "$POWER_W" ] && ls /sys/class/powercap/intel-rapl:* &>/dev/null; then
    RAPL_UW=$(cat /sys/class/powercap/intel-rapl:0/energy_uj 2>/dev/null || true)
    if [[ "$RAPL_UW" =~ ^[0-9]+$ ]]; then
        POWER_W="CPU-only (RAPL)"
        SOURCE="Intel RAPL (CPU only)"
    fi
fi

############################
# RESULTAT
############################
if [ -z "$POWER_W" ]; then
    echo "⚡ Strömförbrukning: Value cannot be found"
    echo "❌ Ingen hårdvarusensor exponerar ström"
    echo ""
    echo "📅 Per månad: Value cannot be found"
    echo "📅 Per år:    Value cannot be found"
    echo "==============================="
    exit 0
fi

echo "⚡ Strömförbrukning: $POWER_W W"
echo "🔎 Källa: $SOURCE"

############################
# BERÄKNING
############################
H=24
M=30
Y=365

MONTH_KWH=$(echo "scale=2; $POWER_W*$H*$M/1000" | bc)
YEAR_KWH=$(echo "scale=2; $POWER_W*$H*$Y/1000" | bc)

echo ""
echo "📅 Per månad: $MONTH_KWH kWh"
echo "📅 Per år:    $YEAR_KWH kWh"
echo "==============================="
