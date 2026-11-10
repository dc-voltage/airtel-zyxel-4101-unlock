#!/bin/sh
# ==============================================================================
# Universal Standalone 5G CPE Unlock & Gateway Framework
# Hardware: Zyxel NR7002 / AOD4101ZY Outdoor Unit (ODU)
# SoC: MediaTek MT6890 / T750 | Baseband: Quectel RG500L-ARS
# Fully De-branded Zyxel Firmware & Jio / Airtel / Vi 5G Universal Support
# ==============================================================================

echo "[+] Step 1: Disabling Airtel Carrier Daemons, Watchdogs & Remote TR-069..."
chmod 000 /usr/bin/ztr69 /usr/bin/emdlogger1 /usr/sbin/HostsUpdater /usr/sbin/cm /usr/bin/scd 2>/dev/null
echo "exit 0" > /usr/script/greMonitorAgent.sh 2>/dev/null
echo "exit 0" > /usr/script/greTryToDoAgent.sh 2>/dev/null
chmod +x /usr/script/greMonitorAgent.sh /usr/script/greTryToDoAgent.sh 2>/dev/null

# Disable AP Locking scripts & remove restrictions
echo "exit 0" > /usr/bin/SET_APLockingData.sh 2>/dev/null
chmod +x /usr/bin/SET_APLockingData.sh 2>/dev/null
rm -f /app/AP_LOCKING /tmp/sysinfo/apLocking_list 2>/dev/null

# Disable AN8855 Switch L2 ACL MAC Filtering permanently
switch an8855 acl set en 0 2>/dev/null
switch an8855 acl clear rule 2>/dev/null
switch an8855 acl clear udfRule 2>/dev/null
switch an8855 acl clear action 2>/dev/null
greTool whitelist reset 2>/dev/null

# Disable baseband memory logger (frees >80 MB RAM)
/etc/init.d/mdlogger disable 2>/dev/null
/etc/init.d/mdlogger stop 2>/dev/null

# Disable auto-reboot watchdog on modem reset
uci set scd.features.modem_reboot_ap="0" 2>/dev/null
uci commit scd 2>/dev/null
/etc/init.d/scd disable 2>/dev/null
/etc/init.d/scd stop 2>/dev/null

# Clean any spinning cmdsh crontab entries
sed -i "/luci-main-web/d" /etc/crontabs/root /etc/crontabs/admin 2>/dev/null
killall -9 cmdsh 2>/dev/null

# Kill remaining bloatware processes
for p in $(ps | grep -E "ztr69|emdlogger1|HostsUpdater|cm$|greMonitor|greTry|scd" | grep -v grep | awk "{print \$1}"); do
    kill -9 "$p" 2>/dev/null
done

echo "[+] Step 2: Unlocking UART Console & USB Gadget (ADB/CCCI)..."
[ -f /etc/releaseVersion ] && mv /etc/releaseVersion /etc/releaseVersion.disabled 2>/dev/null
[ ! -c /dev/ttyS0 ] && mknod -m 600 /dev/ttyS0 c 4 64 2>/dev/null
[ ! -c /dev/console ] && mknod -m 600 /dev/console c 5 1 2>/dev/null

uci set usb.adb.service_adb_enable="1" 2>/dev/null
uci set usb.adb.service_adb_tcp_port="5555" 2>/dev/null
uci set usb.config.mipcboot="0" 2>/dev/null
uci set network.wan.ql_monitor="0" 2>/dev/null
uci commit usb 2>/dev/null
uci commit network 2>/dev/null
[ -x /etc/init.d/adb-tcp ] && /etc/init.d/adb-tcp restart 2>/dev/null

echo "[+] Step 3: Configuring Radio & Universal 5G SA/NSA APN (jionet)..."
mipc_wan_cli --at_cmd="AT+ESIMMAP=1" >/dev/null 2>&1
mipc_wan_cli --apn_ia_set jionet 3 3 0 >/dev/null 2>&1
mipc_wan_cli --at_cmd="AT+CGDCONT=1,\"IPV4V6\",\"jionet\"" >/dev/null 2>&1
mipc_wan_cli --at_cmd="AT+CGDCONT=2,\"IPV4V6\",\"jionet\"" >/dev/null 2>&1
mipc_wan_cli --nw_set_rat 15 >/dev/null 2>&1

echo "[+] Step 4: Flushing Airtel Filters & Opening Forwarding / NAT..."
ebtables -F 2>/dev/null
ebtables -t broute -F 2>/dev/null
ebtables -t nat -F 2>/dev/null
iptables -F GRE_FORWARD 2>/dev/null
ip6tables -F GRE_FORWARD 2>/dev/null

# Input filters
iptables -I INPUT 1 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 2>/dev/null
iptables -I INPUT 1 -i lo -j ACCEPT 2>/dev/null
iptables -I INPUT 1 -i 464-clatd -j ACCEPT 2>/dev/null
iptables -I INPUT 1 -i br0 -j ACCEPT 2>/dev/null

ip6tables -I INPUT 1 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 2>/dev/null
ip6tables -I INPUT 1 -i lo -j ACCEPT 2>/dev/null
ip6tables -I INPUT 1 -i 464-clatd -j ACCEPT 2>/dev/null
ip6tables -I INPUT 1 -i br0 -j ACCEPT 2>/dev/null

# Forwarding and NAT rules for 464XLAT & LAN
iptables -C FORWARD -i br0 -o 464-clatd -j ACCEPT 2>/dev/null || iptables -I FORWARD 1 -i br0 -o 464-clatd -j ACCEPT
iptables -C FORWARD -i 464-clatd -o br0 -j ACCEPT 2>/dev/null || iptables -I FORWARD 1 -i 464-clatd -o br0 -j ACCEPT
iptables -t nat -C POSTROUTING -o 464-clatd -j MASQUERADE 2>/dev/null || iptables -t nat -I POSTROUTING 1 -o 464-clatd -j MASQUERADE
iptables -t nat -C NAT_POSTROUTING -o 464-clatd -j MASQUERADE 2>/dev/null || iptables -t nat -I NAT_POSTROUTING 1 -o 464-clatd -j MASQUERADE

# TCP MSS clamping to 1340 for cellular MTU
iptables -t mangle -C FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1340 2>/dev/null || iptables -t mangle -I FORWARD 1 -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1340
iptables -t mangle -C POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1340 2>/dev/null || iptables -t mangle -I POSTROUTING 1 -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1340

# IPv6 native forwarding
ip6tables -C FORWARD -i br0 -o ccmni+ -j ACCEPT 2>/dev/null || ip6tables -I FORWARD 1 -i br0 -o ccmni+ -j ACCEPT
ip6tables -C FORWARD -i ccmni+ -o br0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || ip6tables -I FORWARD 1 -i ccmni+ -o br0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
ip6tables -t mangle -C FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null || ip6tables -t mangle -I FORWARD 1 -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv6/conf/all/forwarding

echo "[+] Step 5: Configuring Clean Public DNS & DHCP..."
printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\nnameserver 2405:200:800::11\n" > /etc/resolv.conf
printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\nnameserver 2405:200:800::11\n" > /var/fyi/sys/dns 2>/dev/null

for conf in /etc/IPP_file/udhcpd.conf /etc/udhcpd.conf; do
    if [ -f "$conf" ]; then
        sed -i "s/^opt router .*/opt router 192.168.0.1/" "$conf"
        sed -i "s/^opt dns .*/opt dns 192.168.0.1 1.1.1.1 8.8.8.8/" "$conf"
    fi
done

echo "[+] Step 6: Initializing 464XLAT (CLAT) & Carrier IPv6 Routing..."
# Wait up to 60 seconds for cellular interface to receive IPv6 address from network
ACT_IF=""
for i in $(seq 1 30); do
    for d in ccmni1 ccmni0 ccmni2 ccmni3; do
        if ip -6 addr show dev "$d" 2>/dev/null | grep -q "inet6 2409:"; then
            ACT_IF="$d"
            break 2
        fi
    done
    # If wan is not up, kick ifup wan
    if ! ubus call network.interface.wan status 2>/dev/null | grep -q "\"up\": true"; then
        ifup wan 2>/dev/null
    fi
    sleep 2
done

if [ -n "$ACT_IF" ]; then
    CLAT_IP6=$(grep -o "local.v6 [^/]*" /proc/net/nat46/control 2>/dev/null | awk "{print \$2}")
    if [ -z "$CLAT_IP6" ] || ! ip link show dev 464-clatd >/dev/null 2>&1; then
        echo del 464-clatd > /proc/net/nat46/control 2>/dev/null
        rm -f /var/run/464-clatd.pid 2>/dev/null
        CLAT_IP6=$(/sbin/464xlatcfg 464-clatd "$ACT_IF" 64:ff9b::/96 192.0.0.1 2>/dev/null)
        sleep 1
    fi
    [ -z "$CLAT_IP6" ] && CLAT_IP6=$(grep -o "local.v6 [^/]*" /proc/net/nat46/control 2>/dev/null | awk "{print \$2}")

    if [ -n "$CLAT_IP6" ]; then
        # Remove vendor drop rules
        ip -6 rule del pref 4200000001 2>/dev/null
        ip -6 rule del iif 464-clatd failed_policy 2>/dev/null
        ip -6 rule del iif "$ACT_IF" failed_policy 2>/dev/null

        # Ensure prelocal routing directs inbound NAT64 replies into nat46 device
        ip -6 rule del pref 0 2>/dev/null
        ip -6 rule del pref 1 2>/dev/null
        ip -6 rule add from all lookup local pref 1 2>/dev/null
        ip -6 rule add to "$CLAT_IP6" lookup prelocal pref 0 2>/dev/null
        ip -6 route replace "$CLAT_IP6" dev 464-clatd table prelocal 2>/dev/null

        ip link set dev 464-clatd mtu 1400 2>/dev/null
        ip link set dev 464-clatd up 2>/dev/null
        ip addr add 192.0.0.1/32 dev 464-clatd 2>/dev/null
        ip route replace default dev 464-clatd src 192.0.0.1 2>/dev/null
    fi
fi

# Run hotplug sync
/usr/bin/clat_hotplug.sh >/dev/null 2>&1

# Start background persistent health watchdog if not already running
if ! ps | grep -v grep | grep -q "odu_watchdog.sh"; then
    /usr/bin/odu_watchdog.sh &
fi

/usr/bin/set_led.sh green 2>/dev/null
echo "[+] Universal Zyxel NR7002 Unlock Successfully Applied!"
