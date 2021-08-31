#!/bin/sh

# Use the command below to parse multiple dtoverlay statements in config.txt using the SV API 
# cat /mnt/boot/config.txt | grep -r "dtoverlay" /mnt/boot/config.txt | awk -F= 'BEGIN { ORS="" }; {print "\""$2"\""}' | head -c -1

# Use the command below to parse through a single line of dtoverlay in the config.txt 
cat /mnt/boot/config.txt | grep -r "dtoverlay" /mnt/boot/config.txt | cut -c 11- | awk '{print "\""$1"\""}'
