#!/bin/sh
#
# Copyright 2018 Resinio Ltd.
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

TIMESTAMP=/etc/timestamp

if [ ! -f $TIMESTAMP ]; then
	echo "[ERROR] $TIMESTAMP not found."
	exit 1
fi

SYS_TIME=$(date -u "+%4Y%2m%2d%2H%2M%2S")
BUILD_TIME=$(cat $TIMESTAMP)

if [ "$SYS_TIME" -lt "$BUILD_TIME" ]; then
	echo "[INFO] Updating systemd time from build time."
	BUILD_DATETIME="$(echo "$BUILD_TIME" | awk '{string=substr($0, 5, 8); print string;}')"
	BUILD_YEAR="$(echo "$BUILD_TIME" | awk '{string=substr($0, 1, 4); print string;}')"
	BUILD_SEC="$(echo "$BUILD_TIME" | awk '{string=substr($0, 13, 2); print string;}')"
	date -u "${BUILD_DATETIME}${BUILD_YEAR}.${BUILD_SEC}"
else
	echo "[INFO] Systemd date already updated."
fi
