#!/bin/sh
# ==============================================================================
# Zyxel F4101 / AOD4101ZYR LED Control Utility
# Target Hardware: Zyxel NR7002 / MediaTek MT6890
# Controls RGB GPIO LEDs: led_5g_red, led_5g_green, led_5g_blue
# ==============================================================================

set_led() {
    local red="$1"
    local green="$2"
    local blue="$3"
    local trigger="$4"

    [ -z "$trigger" ] && trigger="none"

    echo "$trigger" > /sys/class/leds/led_5g_red/trigger 2>/dev/null || true
    echo "$red"     > /sys/class/leds/led_5g_red/brightness 2>/dev/null || true

    echo "$trigger" > /sys/class/leds/led_5g_green/trigger 2>/dev/null || true
    echo "$green"   > /sys/class/leds/led_5g_green/brightness 2>/dev/null || true

    echo "$trigger" > /sys/class/leds/led_5g_blue/trigger 2>/dev/null || true
    echo "$blue"    > /sys/class/leds/led_5g_blue/brightness 2>/dev/null || true
}

case "$1" in
    blue|b)
        set_led 0 0 255 none
        echo "[+] LED configured: Solid BLUE (5G Connected)"
        ;;
    green|g)
        set_led 0 255 0 none
        echo "[+] LED configured: Solid GREEN (Online / Normal)"
        ;;
    cyan|c)
        set_led 0 255 255 none
        echo "[+] LED configured: Solid CYAN (5G High Performance)"
        ;;
    amber|yellow|y)
        set_led 128 255 0 none
        echo "[+] LED configured: Solid AMBER (Standby / Moderate Signal)"
        ;;
    red|r)
        set_led 255 0 0 none
        echo "[+] LED configured: Solid RED (Alert / Error)"
        ;;
    blink-red)
        set_led 255 0 0 timer
        echo "[+] LED configured: Blinking RED (Searching / Disconnected)"
        ;;
    off)
        set_led 0 0 0 none
        echo "[+] LED configured: Completely OFF"
        ;;
    *)
        echo "Usage: $0 {green|blue|cyan|amber|red|blink-red|off}"
        echo "Defaulting to: Solid GREEN (Online)"
        set_led 0 255 0 none
        ;;
esac
exit 0
