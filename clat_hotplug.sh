#!/bin/sh
# Hotplug / Event-driven CLAT & Gateway Configuration for Jio 5G SA
logger -t clat_hotplug "Interface event for: $INTERFACE action: $ACTION"

# Disable switch hardware ACL
switch an8855 acl set en 0 2>/dev/null
greTool whitelist reset 2>/dev/null

# Kernel forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward 2>/dev/null
echo 1 > /proc/sys/net/ipv6/conf/all/forwarding 2>/dev/null

# Detect cellular interface with Jio IPv6
ACT_IF=""
for d in ccmni1 ccmni0 ccmni2 ccmni3; do
    if ip -6 addr show dev "$d" 2>/dev/null | grep -q "inet6 2409:"; then
        ACT_IF="$d"
        break
    fi
done

# If 464-clatd is not running but we have cellular IPv6, trigger clatd
if [ -n "$ACT_IF" ] && ! ip link show dev 464-clatd >/dev/null 2>&1; then
    ifup clatd 2>/dev/null
    sleep 1
fi

# Obtain local.v6 address from nat46 control
CLAT_IP6=$(grep -o "local.v6 [^/]*" /proc/net/nat46/control 2>/dev/null | awk "{print \$2}")

if [ -n "$CLAT_IP6" ]; then
    # Fix rule priority and prelocal routing
    ip -6 rule del pref 0 2>/dev/null
    ip -6 rule del pref 1 2>/dev/null
    ip -6 rule add from all lookup local pref 1 2>/dev/null
    ip -6 rule add to "$CLAT_IP6" lookup prelocal pref 0 2>/dev/null
    ip -6 route replace "$CLAT_IP6" dev 464-clatd table prelocal 2>/dev/null

    # Default IPv4 route through 464-clatd
    ip route replace default dev 464-clatd src 192.0.0.1 2>/dev/null

    # Remove vendor carrier drop rules
    ip -6 rule del pref 4200000001 2>/dev/null
    ip -6 rule del iif 464-clatd failed_policy 2>/dev/null
    ip -6 rule del iif "$ACT_IF" failed_policy 2>/dev/null

    # Setup iptables FORWARD and NAT for 464-clatd and br0
    iptables -C FORWARD -i br0 -o 464-clatd -j ACCEPT 2>/dev/null || iptables -I FORWARD 1 -i br0 -o 464-clatd -j ACCEPT
    iptables -C FORWARD -i 464-clatd -o br0 -j ACCEPT 2>/dev/null || iptables -I FORWARD 1 -i 464-clatd -o br0 -j ACCEPT
    iptables -t nat -C POSTROUTING -o 464-clatd -j MASQUERADE 2>/dev/null || iptables -t nat -I POSTROUTING 1 -o 464-clatd -j MASQUERADE
    iptables -t nat -C NAT_POSTROUTING -o 464-clatd -j MASQUERADE 2>/dev/null || iptables -t nat -I NAT_POSTROUTING 1 -o 464-clatd -j MASQUERADE

    # TCP MSS clamping to prevent fragmentation drops on 5G MTU
    iptables -t mangle -C FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1340 2>/dev/null || iptables -t mangle -I FORWARD 1 -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1340
    iptables -t mangle -C POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1340 2>/dev/null || iptables -t mangle -I POSTROUTING 1 -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1340

    # Clean DNS
    if ! grep -q "8.8.8.8" /etc/resolv.conf 2>/dev/null; then
        printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\nnameserver 2405:200:800::11\n" > /etc/resolv.conf
    fi
    logger -t clat_hotplug "464XLAT successfully aligned with IP6: $CLAT_IP6"
fi
