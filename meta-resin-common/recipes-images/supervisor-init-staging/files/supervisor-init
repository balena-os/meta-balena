#!/bin/sh

rce --restart=false -s btrfs -d -g /var/lib/rce &

# Wait for rce to become ready
echo "Waiting for rce to become ready.."
while [ ! -S /var/run/rce.sock ]
do
	sleep 1
done

# Remove supervisor from previous boot.
# We have to make sure nobody started it before removing.
rce stop resin_supervisor || true
rce rm resin_supervisor || true

# Run supervisor
echo "Starting Supervisor.."
rce-run-supervisor

source /etc/resin.conf
export API_ENDPOINT CONFIG_PATH
resin-device-progress "" "Finished" || true

while [ ! -d /resin-data/resin-supervisor ]
do
	sleep 1
done

# Disable power management.
iwconfig wlan0 power off

# Open socket for supervisor to connect to the host
bash -c 'while true; do rm -f /resin-data/resin-supervisor/host; socat UNIX-LISTEN:/resin-data/resin-supervisor/host EXEC:/bin/bash,pty,setsid,setpgid,stderr,ctty; done' &
