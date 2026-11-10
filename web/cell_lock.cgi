#!/bin/sh
printf 'Status: 200 OK\r\nContent-Type: application/json\r\nConnection: close\r\n\r\n'

if [ "$REQUEST_METHOD" = "POST" ]; then
    read -r POST_BODY
    QUERY="$POST_BODY"
else
    QUERY="$QUERY_STRING"
fi

ACTION=$(echo "$QUERY" | tr '&' '\n' | grep '^action=' | cut -d= -f2)
PCI=$(echo "$QUERY" | tr '&' '\n' | grep '^pci=' | cut -d= -f2)
ARFCN=$(echo "$QUERY" | tr '&' '\n' | grep '^arfcn=' | cut -d= -f2)
RAT=$(echo "$QUERY" | tr '&' '\n' | grep '^rat=' | cut -d= -f2)

case "$ACTION" in
    lock)
        [ -z "$ARFCN" ] && ARFCN="627264"
        [ -z "$PCI" ] && PCI="464"
        RES=$(/usr/bin/mipc_wan_cli --at_cmd="AT+EMMCHLCK=1,11,0,$ARFCN,$PCI" 2>&1 | tr '\r\n' ' ')
        printf '{"status":"ok","action":"lock","arfcn":"%s","pci":"%s","result":"%s"}\n' "$ARFCN" "$PCI" "$RES"
        ;;
    unlock)
        RES=$(/usr/bin/mipc_wan_cli --at_cmd="AT+EMMCHLCK=0" 2>&1 | tr '\r\n' ' ')
        printf '{"status":"ok","action":"unlock","result":"%s"}\n' "$RES"
        ;;
    rat)
        if [ "$RAT" = "5g_sa" ]; then
            RES=$(/usr/bin/mipc_wan_cli --nw_set_rat=15 2>&1 | tr '\r\n' ' ')
        elif [ "$RAT" = "lte_5g" ]; then
            RES=$(/usr/bin/mipc_wan_cli --nw_set_rat=14 2>&1 | tr '\r\n' ' ')
        else
            RES=$(/usr/bin/mipc_wan_cli --nw_set_rat=0 2>&1 | tr '\r\n' ' ')
        fi
        printf '{"status":"ok","action":"rat","rat":"%s","result":"%s"}\n' "$RAT" "$RES"
        ;;
    status)
        LOCK_STATUS=$(/usr/bin/mipc_wan_cli --at_cmd="AT+EMMCHLCK?" 2>&1 | tr '\r\n' ' ')
        printf '{"status":"ok","action":"status","lock":"%s"}\n' "$LOCK_STATUS"
        ;;
    *)
        printf '{"status":"error","message":"unknown action"}\n'
        ;;
esac
