#!/bin/sh

cat /mnt/boot/config.txt | grep -r "dtoverlay" /mnt/boot/config.txt | awk -F= 'BEGIN { ORS="," }; {print "\""$2"\""}' | head -c -1
