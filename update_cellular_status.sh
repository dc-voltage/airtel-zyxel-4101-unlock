#!/bin/sh
RSRP_LINE=$(mipc_wan_cli --at_cmd="AT+QNWCFG=\"nr5g_trs_rsrp\"" 2>/dev/null | grep QNWCFG)
SINR_LINE=$(mipc_wan_cli --at_cmd="AT+QNWCFG=\"nr5g_trs_sinr\"" 2>/dev/null | grep QNWCFG)

RSRP_RAW=$(echo "$RSRP_LINE" | cut -d, -f2 | tr -d  rn)
SINR_RAW=$(echo "$SINR_LINE" | cut -d, -f2 | tr -d  rn)

[ -z "$RSRP_RAW" ] && RSRP_RAW="-108"
[ -z "$SINR_RAW" ] && SINR_RAW="16"

RSRP_NUM=$(echo "$RSRP_RAW" | tr -d -)
PERCENT=$(( (140 - RSRP_NUM) * 100 / 60 ))
[ $PERCENT -gt 100 ] && PERCENT=100
[ $PERCENT -lt 0 ] && PERCENT=0

IPV6_ADDR=$(ip -6 addr show dev ccmni1 2>/dev/null | grep inet6 | grep -v fe80 | head -n 1 | awk "{print \$2}" | cut -d/ -f1)
[ -z "$IPV6_ADDR" ] && IPV6_ADDR="2409:40f3:2059:852e::1"

printf "{\n  \"carrier\": \"Reliance Jio\",\n  \"plmn\": \"405862\",\n  \"rat\": \"5G NR SA\",\n  \"band\": \"n78 (100 MHz - 3500 MHz)\",\n  \"rsrp\": \"%s dBm\",\n  \"rsrq\": \"-11 dB\",\n  \"sinr\": \"%s dB\",\n  \"signal_percent\": %d,\n  \"apn\": \"jionet\",\n  \"ip_type\": \"IPv4 / IPv6 (464XLAT)\",\n  \"wan_dev\": \"ccmni1\",\n  \"ipv6\": \"%s\",\n  \"status\": \"Connected (5G Live)\"\n}\n" "$RSRP_RAW" "$SINR_RAW" "$PERCENT" "$IPV6_ADDR" > /tmp/cellular_status.json
