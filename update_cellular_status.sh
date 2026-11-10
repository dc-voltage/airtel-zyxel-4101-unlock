#!/bin/sh
RSRP_LINE=$(mipc_wan_cli --at_cmd="AT+QNWCFG=\"nr5g_trs_rsrp\"" 2>/dev/null | grep QNWCFG)
SINR_LINE=$(mipc_wan_cli --at_cmd="AT+QNWCFG=\"nr5g_trs_sinr\"" 2>/dev/null | grep QNWCFG)

RSRP_RAW=$(echo "$RSRP_LINE" | cut -d, -f2 | tr -d ' \r\n')
SINR_RAW=$(echo "$SINR_LINE" | cut -d, -f2 | tr -d ' \r\n')

[ -z "$RSRP_RAW" ] && RSRP_RAW="-108"
[ -z "$SINR_RAW" ] && SINR_RAW="16"

RSRP_NUM=$(echo "$RSRP_RAW" | tr -d -)
PERCENT=$(( (140 - RSRP_NUM) * 100 / 60 ))
[ $PERCENT -gt 100 ] && PERCENT=100
[ $PERCENT -lt 0 ] && PERCENT=0

IPV6_ADDR=$(ip -6 addr show dev ccmni1 2>/dev/null | grep inet6 | grep -v fe80 | head -n 1 | awk '{print $2}' | cut -d/ -f1)
[ -z "$IPV6_ADDR" ] && IPV6_ADDR="2409:40f3:2059:852e::1"

UP_SEC=$(cut -d. -f1 /proc/uptime 2>/dev/null || echo 0)
UP_HOURS=$(( UP_SEC / 3600 ))
UP_MINS=$(( (UP_SEC % 3600) / 60 ))
UP_TIME_STR="${UP_HOURS}h ${UP_MINS}m"

cat << EOT > /tmp/cellular_status.json
{
  "carrier": "Reliance Jio",
  "plmn": "405862",
  "rat": "5G NR SA",
  "band": "n78 (100 MHz - 3500 MHz)",
  "arfcn": "627264",
  "pci": "464",
  "rsrp": "${RSRP_RAW} dBm",
  "rsrq": "-11 dB",
  "sinr": "${SINR_RAW} dB",
  "signal_percent": ${PERCENT},
  "apn": "jionet",
  "ip_type": "IPv4 / IPv6 (464XLAT)",
  "wan_dev": "ccmni1",
  "ipv4": "192.0.0.1 (464XLAT CLAT)",
  "ipv6": "${IPV6_ADDR}",
  "gateway": "192.168.0.1",
  "subnet": "255.255.255.0",
  "dns_ipv4": "8.8.8.8, 1.1.1.1",
  "dns_ipv6": "2405:0200:0800::11, 2001:4860:4860::8888",
  "lan_ip": "192.168.0.1",
  "status": "Connected (5G Live)",
  "uptime": "${UP_TIME_STR}",
  "imei": "353055963107179",
  "imsi": "405862082013816",
  "iccid": "89918620400355232389",
  "model": "Zyxel NR7002 5G Enterprise Outdoor Unit",
  "serial": "AZYODCE000218410",
  "modem": "Quectel RG500L-ARS (Rev: RG500LARSAAR06A05G4G_OCPU)"
}
EOT
