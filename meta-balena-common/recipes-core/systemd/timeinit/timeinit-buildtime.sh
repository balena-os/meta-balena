#!/bin/sh
#
# Copyright 2020 Balena Ltd.
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

set -e

. /usr/libexec/os-helpers-logging
. /usr/libexec/os-helpers-time

TIMESTAMP=/etc/timestamp

if [ ! -f $TIMESTAMP ]; then
	fail "$TIMESTAMP not found."
fi

info "Setting system time from build time."

SYS_TIME=$(get_system_time_as_timestamp)
BUILD_TIME=$(cat $TIMESTAMP)

if [ "$SYS_TIME" -lt "$BUILD_TIME" ]; then
	$(set_system_time_from_timestamp "$BUILD_TIME")
	info "Old time: $(get_display_time_from_timestamp "$SYS_TIME")"
	info "New time: $(get_display_time_from_timestamp "$BUILD_TIME")"
else
	info "System time already set."
fi
