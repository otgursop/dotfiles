#!/bin/bash

if ip link show tun0 2>/dev/null | grep -q "state UNKNOWN"; then
    echo "VPN"
else
    echo ""
fi
