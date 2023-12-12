#!/bin/sh
#
# Copyright 2021 Balena Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

. /usr/libexec/os-helpers-logging
. /usr/libexec/os-helpers-time

. /usr/sbin/balena-config-vars

# Expected HTTP response code. Used to determine that we are not
# behind a captive portal.
EXPECTED_SERVER_CODE=204
# Initial delay in seconds between poll attempts.
INITIAL_HTTPS_POLL_DELAY=2
# Maximum delay in seconds between poll attempts.
MAX_HTTPS_POLL_DELAY=64
# Timeout for curl command in seconds.
# Note that curl does not apply this timeout to DNS lookups.
CURL_TIMEOUT=5
# Don't bother updating or reporting errors for small differences.
TIME_DIFF_THRESHOLD=2

# Poll HTTPS server for time string.
info "Starting HTTPS time synchronisation."

HTTPS_POLL_DELAY=$INITIAL_HTTPS_POLL_DELAY

# In theory the maximum duration of each poll delay is given by:
#     (HTTPS_POLL_DELAY + CURL_TIMEOUT) seconds.
# Note that this period can be extended as curl DNS lookup timeouts do
# not obey the -m (--max-time) parameter.

if [ -z "$OS_NET_CONN_URI" ] || [ "$OS_NET_CONN_URI" = "null" ]; then
	warn "Connectivity URL not defined - skipping HTTPS synchronisation."
	exit 0
fi

while [ true  ]; do
	SYS_TIME=$(get_system_time_as_timestamp)
	readarray -t https_header <<<$(curl -m10 -k -I -s $OS_NET_CONN_URI | sed 's/\r$//'  | awk '/HTTP/{printf $2"\n"} /[Dd]ate/{print $2, $3, $4, $5, $6, $7"\n"}')
	SERVER_CODE=${https_header[0]}
	SERVER_TIME_STRING=${https_header[1]}
	if [ "$SERVER_CODE" = "$EXPECTED_SERVER_CODE" ]; then
		if [ ! -z "$SERVER_TIME_STRING" ]; then
			SERVER_TIME=$(get_server_time_as_timestamp "$SERVER_TIME_STRING")
			TIME_DIFF=$(get_abs_time_diff_from_timestamps "$SYS_TIME" "$SERVER_TIME")
			if [ "$TIME_DIFF" -gt "$TIME_DIFF_THRESHOLD" ]; then
				$(set_system_time_from_timestamp "$SERVER_TIME")
				if [ "$SYS_TIME" -gt "$SERVER_TIME" ]; then
					warn "HTTPS header time is in the past."
					warn "Check time sources if this issue persists."
				fi
				info "Time synchronised via HTTPS."
				info "Old time: $(get_display_time_from_timestamp "$SYS_TIME")"
				info "New time: $(get_display_time_from_timestamp "$SERVER_TIME")"
				hwclock -w || true
				exit 0
			else
				info "System time is already synchronised."
				exit 0
			fi
		else
			warn "HTTPS header did not return a date field."
			warn "System time not updated."
			exit 0
		fi
	fi
	sleep $HTTPS_POLL_DELAY

	if [ "$HTTPS_POLL_DELAY" -lt "$MAX_HTTPS_POLL_DELAY" ]; then
		HTTPS_POLL_DELAY=$(($HTTPS_POLL_DELAY * 2))
	fi
done
