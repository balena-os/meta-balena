#!/bin/sh

cat /mnt/boot/config.txt | grep -r "dtparam" /mnt/boot/config.txt | awk -F= 'BEGIN { ORS="," }; {print "\""$2"\="$3"\""}' | head -c -1
