#!/bin/sh
# ODU 464XLAT, Switch & Gateway Health Watchdog
FAIL_COUNT=0

while true; do
    sleep 15
    /usr/bin/update_cellular_status.sh >/dev/null 2>&1
    # Always keep AN8855 switch hardware ACL disabled
    switch an8855 acl set en 0 >/dev/null 2>&1

    if ! ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1 && ! ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1; then
        FAIL_COUNT=$((FAIL_COUNT + 1))
        logger -t odu_watchdog "Gateway ping failed (count: $FAIL_COUNT)"
        
        # Trigger hotplug realignment
        /usr/bin/clat_hotplug.sh >/dev/null 2>&1
        
        if [ $FAIL_COUNT -ge 2 ]; then
            logger -t odu_watchdog "Re-running universal CPE unlock..."
            /usr/bin/universal_cpe_unlock.sh >/dev/null 2>&1 &
            FAIL_COUNT=0
            sleep 10
        fi
    else
        FAIL_COUNT=0
    fi
done
