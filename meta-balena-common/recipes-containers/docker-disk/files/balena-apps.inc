#!/bin/bash

set -x

CURL="curl -s"

TRANSLATION=${TRANSLATION:-"v6"}

. /balena-api.inc

DEBUG=0

__dlog() {
	if [ "${DEBUG}" = "1" ]; then
		>&2 echo "${1}"
	fi
}

imageid_from_digest() {
	local _image="$1"
	local _digest
	local _image_name
	local _imageid
	local _digest_check
	_image_name=$(echo "${_image}" | cut -d "@" -f1)
	_digest=$(echo "${_image}" | cut -d "@" -f2)
	_imageid=$(docker images --filter=reference="${_image_name}" --format "{{.ID}}")
	_digest_check=$(docker images --digests --filter=reference="${_image_name}" --format "{{.Digest}}")
	if [ "${_digest}" = "${_digest_check}" ]; then
		echo "${_imageid}"
	fi
}
