#!/bin/bash

mkdir -p /run/openvpn/vpn_status
touch /run/openvpn/vpn_status/active
chown -R openvpn:openvpn /run/openvpn/vpn_status

# resin-ntp-config sets up ntp servers from config.json
/usr/bin/resin-ntp-config
