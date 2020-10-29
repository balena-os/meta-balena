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

TIMESTAMP=/etc/timestamp

if [ ! -f $TIMESTAMP ]; then
	fail "$TIMESTAMP not found."
fi

info "Setting system time from build time."

SYS_TIME=$(date -u "+%4Y%2m%2d%2H%2M%2S")
BUILD_TIME=$(cat $TIMESTAMP)

OLD_SYS_TIME=$(date -d "${SYS_TIME:0:8} ${SYS_TIME:8:2}:${SYS_TIME:10:2}:${SYS_TIME:12:2}")
NEW_SYS_TIME=$(date -d "${BUILD_TIME:0:8} ${BUILD_TIME:8:2}:${BUILD_TIME:10:2}:${BUILD_TIME:12:2}")

if [ "$SYS_TIME" -lt "$BUILD_TIME" ]; then
	BUILD_DATETIME="$(echo "$BUILD_TIME" | awk '{string=substr($0, 5, 8); print string;}')"
	BUILD_YEAR="$(echo "$BUILD_TIME" | awk '{string=substr($0, 1, 4); print string;}')"
	BUILD_SEC="$(echo "$BUILD_TIME" | awk '{string=substr($0, 13, 2); print string;}')"
	date -u "${BUILD_DATETIME}${BUILD_YEAR}.${BUILD_SEC}" > /dev/null
	info "Old time: $OLD_SYS_TIME"
	info "New time: $NEW_SYS_TIME"
else
	info "System time already set."
fi
