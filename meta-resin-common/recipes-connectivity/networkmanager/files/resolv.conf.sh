#!/bin/sh
#
# NetworkManager helper script. We don't want NM to overwrite
# /etc/resolv.conf, but instead we want it to use /etc/resolv.dnsmasq.
#
# This program is a replacement for 'resolvconf'. Having the real
# resolvconf installed while having both connman and NetworkManager
# available would create some additional complexity.

echo -n > /etc/resolv.dnsmasq
while read line; do
	echo "$line" >> /etc/resolv.dnsmasq
done
