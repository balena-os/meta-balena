#!/bin/sh

cat /sys/kernel/debug/gpio | grep "gpio-4" -m 1 /sys/kernel/debug/gpio | awk '{print "\""$6"\""}'
