#!/bin/sh

set -e
MODEM_TTY_PATH=$1

while true; do
        echo -e "AT+UUSBCONF=2,\"ECM\"\r\n" > $MODEM_TTY_PATH
        sleep 2
        echo -e "AT+CFUN=1,1\r\n" > $MODEM_TTY_PATH
        sleep 20
        if lsusb | grep "1546:1143" > /dev/null; then # test if modem is in ECM mode
                echo "Succesfully switched modem mode"
                reboot
        fi
done
