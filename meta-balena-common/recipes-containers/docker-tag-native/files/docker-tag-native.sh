#!/bin/sh
# Usage: docker-tag-wrapper <image-id> <machine> <basename>

set -eu

IMAGE_ID="$1"
MACHINE="$2"
BASENAME="$3"

BASE_TAG="balenaos-${MACHINE}-${BASENAME}:latest"
DATE_TAG="balenaos-${MACHINE}-${BASENAME}:$(date +%Y%m%d%H%M%S)"

echo "[docker-tag-wrapper] tagging ${IMAGE_ID} -> ${BASE_TAG}, ${DATE_TAG}"

docker tag "${IMAGE_ID}" "${BASE_TAG}"
docker tag "${IMAGE_ID}" "${DATE_TAG}"
