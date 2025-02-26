#!/bin/sh

cat /sys/kernel/debug/gpio | grep "KEY_POWER" -m 1 /sys/kernel/debug/gpio | awk '{print "\""$6"\""}'
