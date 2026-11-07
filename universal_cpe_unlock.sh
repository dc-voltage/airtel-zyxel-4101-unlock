#!/bin/sh
# ==============================================================================
# Universal 5G CPE Unlock & Gateway Framework
# Target Hardware: Zyxel NR7002 / AOD4101ZYR / F4101 ODU
# SoC: MediaTek MT6890 / T750 | Baseband: Quectel RG500L-ARS (MediaTek RIL)
# Operating System: OpenWrt 19.07 (Vendor BusyBox / procd)
# Carrier: Universal (Jio 5G SA n78 100MHz / Airtel / Vi / BSNL)
#
# Sanitized Public Release Template
# ==============================================================================

set -e

echo "[+] ============================================================"
echo "[+] Starting Universal 5G CPE Unlock & Dual-Stack Initialization"
echo "[+] ============================================================"

# ------------------------------------------------------------------------------
# Step 1: Neutralize Carrier Daemons, Provisioning Agents & Reboot Watchdogs
# ------------------------------------------------------------------------------
echo "[+] Step 1: Neutralizing Carrier Daemons & Watchdogs..."

# Strip execute permissions from carrier telemetry and remote provisioning daemons
chmod 000 /usr/bin/ztr69 /usr/bin/emdlogger1 /usr/sbin/HostsUpdater /usr/sbin/cm /usr/bin/scd 2>/dev/null || true

# Neutralize carrier GRE loop monitor scripts
echo "exit 0" > /usr/script/greMonitorAgent.sh 2>/dev/null || true
echo "exit 0" > /usr/script/greTryToDoAgent.sh 2>/dev/null || true
chmod +x /usr/script/greMonitorAgent.sh /usr/script/greTryToDoAgent.sh 2>/dev/null || true

# Disable baseband memory dump logger (Frees over 80MB of RAM)
if [ -x /etc/init.d/mdlogger ]; then
    /etc/init.d/mdlogger disable 2>/dev/null || true
    /etc/init.d/mdlogger stop 2>/dev/null || true
fi

# Neutralize modem disconnect auto-reboot watchdog in scd
if [ -x /sbin/uci ]; then
    uci set scd.features.modem_reboot_ap='0' 2>/dev/null || true
    uci commit scd 2>/dev/null || true
    uci set network.wan.ql_monitor='0' 2>/dev/null || true
    uci commit network 2>/dev/null || true
fi

if [ -x /etc/init.d/scd ]; then
    /etc/init.d/scd disable 2>/dev/null || true
    /etc/init.d/scd stop 2>/dev/null || true
fi

# Purge any stuck or spinning vendor shell instances from crontabs
sed -i '/luci-main-web/d' /etc/crontabs/root /etc/crontabs/admin 2>/dev/null || true
killall -9 cmdsh 2>/dev/null || true

# Terminate remaining active vendor daemon processes
for proc in $(ps | grep -E 'ztr69|emdlogger1|HostsUpdater|cm$|greMonitor|greTry|scd' | grep -v grep | awk '{print $1}'); do
    kill -9 "$proc" 2>/dev/null || true
done

# ------------------------------------------------------------------------------
# Step 2: Unlock Hardware Interfaces (UART Console, ADB & USB Gadgets)
# ------------------------------------------------------------------------------
echo "[+] Step 2: Unlocking UART Console & USB Gadget (ADB/CCCI)..."

# Preserve UART root console (/dev/ttyS0 @ 921600 baud) by masking release flag
if [ -f /etc/releaseVersion ]; then
    mv /etc/releaseVersion /etc/releaseVersion.disabled 2>/dev/null || true
fi

# Ensure vital device nodes exist
[ ! -c /dev/ttyS0 ] && mknod -m 600 /dev/ttyS0 c 4 64 2>/dev/null || true
[ ! -c /dev/console ] && mknod -m 600 /dev/console c 5 1 2>/dev/null || true

# Enable persistent ADB daemon over TCP port 5555
if [ -x /sbin/uci ]; then
    uci set usb.adb.service_adb_enable='1' 2>/dev/null || true
    uci set usb.adb.service_adb_tcp_port='5555' 2>/dev/null || true
    uci set usb.config.mipcboot='0' 2>/dev/null || true
    uci commit usb 2>/dev/null || true
fi

if [ -x /etc/init.d/adb-tcp ]; then
    /etc/init.d/adb-tcp restart 2>/dev/null || true
fi

# ------------------------------------------------------------------------------
# Step 3: Configure Radio Access Technology (RAT) & Jio 5G SA APN Parameters
# ------------------------------------------------------------------------------
echo "[+] Step 3: Configuring Radio, Universal RAT & Jio 5G SA APN..."

# Map physical SIM slot 1
mipc_wan_cli --at_cmd='AT+ESIMMAP=1' >/dev/null 2>&1 || true

# Provision Initial Attach APN ("jionet", IP type IPv4v6, roaming IPv4v6)
mipc_wan_cli --apn_ia_set jionet 3 3 0 >/dev/null 2>&1 || true
mipc_wan_cli --at_cmd='AT+CGDCONT=1,"IPV4V6","jionet"' >/dev/null 2>&1 || true
mipc_wan_cli --at_cmd='AT+CGDCONT=2,"IPV4V6","jionet"' >/dev/null 2>&1 || true

# Force RAT preference: MediaTek RAT 15 (NR5G / LTE multi-mode)
mipc_wan_cli --nw_set_rat 15 >/dev/null 2>&1 || true
mipc_wan_cli --at_cmd='AT+ERAT=15' >/dev/null 2>&1 || true

# Lock supported bands (LTE B1/B3/B40 + NR5G n1/n3/n40/n78 100MHz)
# NOTE: F4101 hardware has no n28 (700MHz) RF filter. Locking to n78 avoids scanning loops!
mipc_wan_cli --at_cmd='AT+EPBSEH=,"00000091","0000000500000080","000000050000008000002000"' >/dev/null 2>&1 || true

# ------------------------------------------------------------------------------
# Step 4: Flush Carrier Firewall Restrictions, Bridge MAC Filters & Open NAT
# ------------------------------------------------------------------------------
echo "[+] Step 4: Flushing Vendor GRE/MAC Filter Chains & Opening Forwarding..."

# Flush link-layer MAC address drop tables (removes hardcoded indoor pairing drops)
ebtables -F 2>/dev/null || true
ebtables -t broute -F 2>/dev/null || true
ebtables -t nat -F 2>/dev/null || true

# Flush vendor GRE drop chains
iptables -F GRE_FORWARD 2>/dev/null || true
ip6tables -F GRE_FORWARD 2>/dev/null || true

# Allow established connections on INPUT
iptables -I INPUT 1 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true
iptables -I INPUT 1 -i lo -j ACCEPT 2>/dev/null || true
iptables -I INPUT 1 -i 464-clatd -j ACCEPT 2>/dev/null || true
iptables -I INPUT 1 -i br0 -j ACCEPT 2>/dev/null || true

ip6tables -I INPUT 1 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true
ip6tables -I INPUT 1 -i lo -j ACCEPT 2>/dev/null || true
ip6tables -I INPUT 1 -i 464-clatd -j ACCEPT 2>/dev/null || true
ip6tables -I INPUT 1 -i br0 -j ACCEPT 2>/dev/null || true

# Forwarding and NAT rules for 464XLAT virtual interface
iptables -C FORWARD -i br0 -o 464-clatd -j ACCEPT 2>/dev/null || iptables -I FORWARD 1 -i br0 -o 464-clatd -j ACCEPT
iptables -C FORWARD -i 464-clatd -o br0 -j ACCEPT 2>/dev/null || iptables -I FORWARD 1 -i 464-clatd -o br0 -j ACCEPT
iptables -t nat -C POSTROUTING -o 464-clatd -j MASQUERADE 2>/dev/null || iptables -t nat -I POSTROUTING 1 -o 464-clatd -j MASQUERADE
iptables -t nat -C NAT_POSTROUTING -o 464-clatd -j MASQUERADE 2>/dev/null || iptables -t nat -I NAT_POSTROUTING 1 -o 464-clatd -j MASQUERADE

# Clamp TCP MSS to 1340 bytes (prevents SSL/TLS handshake drops on cellular MTU 1400)
iptables -t mangle -C FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1340 2>/dev/null || iptables -t mangle -I FORWARD 1 -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1340
iptables -t mangle -C POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1340 2>/dev/null || iptables -t mangle -I POSTROUTING 1 -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1340

# Native IPv6 forwarding & MSS clamping
ip6tables -C FORWARD -i br0 -o ccmni+ -j ACCEPT 2>/dev/null || ip6tables -I FORWARD 1 -i br0 -o ccmni+ -j ACCEPT
ip6tables -C FORWARD -i ccmni+ -o br0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || ip6tables -I FORWARD 1 -i ccmni+ -o br0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
ip6tables -t mangle -C FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null || ip6tables -t mangle -I FORWARD 1 -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

# Enable kernel IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv6/conf/all/forwarding

# ------------------------------------------------------------------------------
# Step 5: Configure Universal Local DNS & DHCP Gateway Distribution
# ------------------------------------------------------------------------------
echo "[+] Step 5: Configuring Universal Local DNS & DHCP Distribution..."

# Configure local dnsmasq forwarding to public & carrier resolvers, sinkholing carrier ACS
cat << 'DEOF' > /etc/dnsmasq.conf
cache-size=1000
no-resolv
server=1.1.1.1
server=8.8.8.8
server=2405:200:800::11
server=2405:200:800::22
all-servers
address=/testacs.airtelbroadband.in/127.0.0.1
address=/testacs.airtelbroadband.in/::1
address=/verne.corteca.airtelbroadband.in/127.0.0.1
address=/verne.corteca.airtelbroadband.in/::1
address=/gre.fwabng.airtelbroadband.in/127.0.0.1
address=/gre.fwabng.airtelbroadband.in/::1
interface=br0
interface=lo
bind-interfaces
DEOF

killall dnsmasq 2>/dev/null || true
dnsmasq -C /etc/dnsmasq.conf 2>/dev/null || true

printf 'nameserver 192.168.0.1\nnameserver 1.1.1.1\nnameserver 8.8.8.8\n' > /etc/resolv.conf
printf 'nameserver 2405:200:800::11\nnameserver 1.1.1.1\nnameserver 8.8.8.8\n' > /var/fyi/sys/dns 2>/dev/null || true

# Update udhcpd options to hand out router IP as gateway and DNS
for conf in /etc/IPP_file/udhcpd.conf /etc/udhcpd.conf; do
    if [ -f "$conf" ]; then
        sed -i 's/^opt router .*/opt router 192.168.0.1/' "$conf"
        sed -i 's/^opt dns .*/opt dns 192.168.0.1 1.1.1.1 8.8.8.8/' "$conf"
    fi
done

# ------------------------------------------------------------------------------
# Step 6: Cellular Baseband Synchronization & 464XLAT Dual-Stack Binding
# ------------------------------------------------------------------------------
echo "[+] Step 6: Initializing Cellular Connection & 464XLAT Gateway..."

# Wait for baseband radio to become fully ready (state 2)
for i in $(seq 1 20); do
    state=$(ql_datacall --nw_radio_state_get 2>/dev/null || echo "0")
    [ "$state" = "2" ] && break
    sleep 1
done

# Trigger WAN interface up if not already connected
if ! ubus call network.interface.wan status 2>/dev/null | grep -q '"up": true'; then
    ifup wan 2>/dev/null || true
fi

# Wait for 464-clatd virtual device to appear
for i in $(seq 1 15); do
    if ip link show dev 464-clatd >/dev/null 2>&1; then
        break
    fi
    sleep 1
done

# Fallback: If netifd did not launch 464-clatd, detect active ccmni device and instantiate
if ! ip link show dev 464-clatd >/dev/null 2>&1; then
    ACT_IF=""
    for d in ccmni0 ccmni1 ccmni2 ccmni3; do
        if ip -6 addr show dev "$d" 2>/dev/null | grep -q 'inet6 2409:'; then
            ACT_IF="$d"
            break
        fi
    done
    if [ -n "$ACT_IF" ]; then
        rm -f /var/run/464-clatd.pid 2>/dev/null || true
        /sbin/464xlatcfg 464-clatd "$ACT_IF" 64:ff9b::/96 192.0.0.1 >/dev/null 2>&1 || true
        sleep 2
    fi
fi

# Configure 464-clatd routes and eliminate kernel failed_policy drop rules
if ip link show dev 464-clatd >/dev/null 2>&1; then
    # Purge loopback and interface failed_policy blockers
    ip -6 rule del pref 4200000001 2>/dev/null || true
    ip -6 rule del iif 464-clatd failed_policy 2>/dev/null || true
    for d in ccmni0 ccmni1 ccmni2 ccmni3; do
        ip -6 rule del iif "$d" failed_policy 2>/dev/null || true
    done

    # Set appropriate cellular MTU, IP endpoint and default IPv4 route
    ip link set dev 464-clatd mtu 1400 2>/dev/null || true
    ip link set dev 464-clatd up 2>/dev/null || true
    ip addr add 192.0.0.1/32 dev 464-clatd 2>/dev/null || true
    ip route replace default dev 464-clatd src 192.0.0.1 2>/dev/null || true
fi

# ------------------------------------------------------------------------------
# Step 7: System Status LED Enforcement (Override Kernel DTS Red Blinking)
# ------------------------------------------------------------------------------
echo "[+] Step 7: Configuring Status LED to Solid Green..."
if [ -x /usr/bin/set_led.sh ]; then
    /usr/bin/set_led.sh green 2>/dev/null || true
else
    echo none > /sys/class/leds/led_5g_red/trigger 2>/dev/null || true
    echo 0 > /sys/class/leds/led_5g_red/brightness 2>/dev/null || true
    echo none > /sys/class/leds/led_5g_green/trigger 2>/dev/null || true
    echo 255 > /sys/class/leds/led_5g_green/brightness 2>/dev/null || true
    echo none > /sys/class/leds/led_5g_blue/trigger 2>/dev/null || true
    echo 0 > /sys/class/leds/led_5g_blue/brightness 2>/dev/null || true
fi

echo "[+] ============================================================"
echo "[+] Universal 5G CPE Unlock Successfully Completed!"
echo "[+] ============================================================"
exit 0
