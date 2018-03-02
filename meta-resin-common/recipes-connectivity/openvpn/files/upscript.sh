#!/bin/bash

mkdir -p /run/openvpn/vpn_status
touch /run/openvpn/vpn_status/active
chown -R openvpn:openvpn /run/openvpn/vpn_status
