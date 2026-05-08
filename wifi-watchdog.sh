#!/usr/bin/env bash
# WiFi watchdog: pings the gateway and restarts wlan0 if unreachable.

IFACE="wlan0"
PING_COUNT=3
PING_TIMEOUT=5  # seconds per ping

gateway=$(ip route show dev "$IFACE" | awk '/default/ {print $3; exit}')

if [[ -z "$gateway" ]]; then
    echo "No default gateway found on $IFACE — skipping check."
    exit 0
fi

if ping -c "$PING_COUNT" -W "$PING_TIMEOUT" -I "$IFACE" "$gateway" &>/dev/null; then
    exit 0
fi

echo "WiFi unreachable (gateway: $gateway). Restarting $IFACE..."
ip link set "$IFACE" down
sleep 3
ip link set "$IFACE" up
