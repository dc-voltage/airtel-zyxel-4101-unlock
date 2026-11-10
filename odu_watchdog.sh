#!/bin/sh
# ODU 464XLAT & Gateway Health Watchdog
FAIL_COUNT=0

while true; do
    sleep 30
    if ! ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1; then
        FAIL_COUNT=$((FAIL_COUNT + 1))
        if [ $FAIL_COUNT -ge 2 ]; then
            # Re-apply 464XLAT routing & rules
            CLAT_IP6=$(grep -o 'local.v6 [^/]*' /proc/net/nat46/control 2>/dev/null | awk '{print $2}')
            if [ -n "$CLAT_IP6" ]; then
                ip -6 rule del pref 0 2>/dev/null
                ip -6 rule del pref 1 2>/dev/null
                ip -6 rule add from all lookup local pref 1 2>/dev/null
                ip -6 rule add to "$CLAT_IP6" lookup prelocal pref 0 2>/dev/null
                ip -6 route replace "$CLAT_IP6" dev 464-clatd table prelocal 2>/dev/null
                ip route replace default dev 464-clatd src 192.0.0.1 2>/dev/null
                ip -6 rule del pref 4200000001 2>/dev/null
            fi
            
            # If still failing, re-run full unlock
            if ! ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
                /usr/bin/universal_cpe_unlock.sh >/dev/null 2>&1
            fi
            FAIL_COUNT=0
        fi
    else
        FAIL_COUNT=0
    fi
done
