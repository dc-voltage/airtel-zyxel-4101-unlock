#!/bin/sh
printf 'Status: 200 OK\r\nContent-Type: application/json\r\nConnection: close\r\n\r\n'
cat /tmp/cellular_status.json 2>/dev/null || echo '{}'
