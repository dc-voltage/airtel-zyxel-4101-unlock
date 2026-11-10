#!/bin/sh
# 464xlat.sh - 464xlat CLAT (Universal Standalone Fixed for Jio 5G SA)
#
# Copyright (c) 2015 Steven Barth <cyrus@openwrt.org>

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. /lib/functions/network.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

proto_464xlat_setup() {
	local cfg="$1"
	local iface="$2"
	local link="464-$cfg"

	local ip6addr ip6prefix tunlink zone
	json_get_vars ip6addr ip6prefix tunlink zone

	[ "$zone" = "-" ] && zone=""

	( proto_add_host_dependency "$cfg" "::" "$tunlink" )

	if [ -z "$tunlink" ] && ! network_find_wan6 tunlink; then
		proto_notify_error "$cfg" "NO_WAN_LINK"
		return
	fi
	network_get_device tundev "$tunlink"

	ip6addr=$(464xlatcfg "$link" "$tundev" "$ip6prefix" 192.0.0.1 $ip6addr)
	if [ -z "$ip6addr" ]; then
		proto_notify_error "$cfg" "CLAT_CONFIG_FAILED"
		return
	fi

	ip -6 rule del from all lookup local 2>/dev/null
	ip -6 rule add from all lookup local pref 1 2>/dev/null
	ip -6 rule add to $ip6addr lookup prelocal pref 0 2>/dev/null
	echo "$ip6addr" > /tmp/464-$cfg-anycast

	# Fix prelocal routing and kernel forwarding
	ip -6 route replace "$ip6addr" dev "$link" table prelocal 2>/dev/null
	ip route replace default dev "$link" src 192.0.0.1 2>/dev/null
	echo 1 > /proc/sys/net/ipv4/ip_forward 2>/dev/null
	echo 1 > /proc/sys/net/ipv6/conf/all/forwarding 2>/dev/null

	# Fix iptables for non-fw3 Zyxel/MSTC architecture
	iptables -C FORWARD -i br0 -o "$link" -j ACCEPT 2>/dev/null || iptables -I FORWARD 1 -i br0 -o "$link" -j ACCEPT
	iptables -C FORWARD -i "$link" -o br0 -j ACCEPT 2>/dev/null || iptables -I FORWARD 1 -i "$link" -o br0 -j ACCEPT
	iptables -t nat -C POSTROUTING -o "$link" -j MASQUERADE 2>/dev/null || iptables -t nat -I POSTROUTING 1 -o "$link" -j MASQUERADE
	iptables -t nat -C NAT_POSTROUTING -o "$link" -j MASQUERADE 2>/dev/null || iptables -t nat -I NAT_POSTROUTING 1 -o "$link" -j MASQUERADE
	switch an8855 acl set en 0 2>/dev/null

	proto_init_update "$link" 1
	proto_add_ipv4_route "0.0.0.0" 0 "" "" 2048
	proto_add_ipv6_route $ip6addr 128 "" "" "" "" 128

	proto_add_data
	[ -n "$zone" ] && json_add_string zone "$zone"

	proto_close_data
	proto_send_update "$cfg"
}

proto_464xlat_teardown() {
	local cfg="$1"
	local link="464-$cfg"

	[ -f /tmp/464-$cfg-anycast ] || return
	local ip6addr=$(cat /tmp/464-$cfg-anycast)

	464xlatcfg "$link"

	rm -rf /tmp/464-$cfg-anycast
	[ -n "$ip6addr" ] && {
		ip -6 route del "$ip6addr" dev "$link" table prelocal 2>/dev/null
		ip -6 rule del to $ip6addr lookup prelocal 2>/dev/null
	}

	if [ -z "$(ls /tmp/464-*-anycast 2>&-)" ]; then
		ip -6 rule del from all lookup local 2>/dev/null
		ip -6 rule add from all lookup local pref 0 2>/dev/null
	fi
}

proto_464xlat_init_config() {
	no_device=1
	available=1

	proto_config_add_string "ip6prefix"
	proto_config_add_string "ip6addr"
	proto_config_add_string "tunlink"
	proto_config_add_string "zone"
}

[ -n "$INCLUDE_ONLY" ] || {
        add_protocol 464xlat
}
