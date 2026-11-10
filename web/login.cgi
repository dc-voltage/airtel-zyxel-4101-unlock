#!/bin/sh
/usr/shared/web/cgi-bin/login.real "$@" | awk '
/^Set-Cookie:/ { print; printf "Content-Type: text/html\r\n\r\n"; next }
{ print }
'
