#!/bin/sh

set -e
MODEM_TTY_PATH=$1

# wait for the modem to be powered on
while [ x`mmcli -m 0 --output-keyvalue 2>/dev/null | grep -i power-state | awk -F ": " '{ print $2 }'` != x"on" ] ; do sleep 1; done

echo -e "AT+UUSBCONF=2,\"ECM\"\r\n" > $MODEM_TTY_PATH

echo -e "AT+CFUN=1,1\r\n" > $MODEM_TTY_PATH
