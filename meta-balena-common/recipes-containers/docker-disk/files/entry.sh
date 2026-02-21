#!/bin/sh

set -o errexit
set -o nounset

DOCKER_TIMEOUT=20 # Wait 20 seconds for docker to start
DATA_VOLUME=/resin-data
BUILD=/build
PARTITION_SIZE=${PARTITION_SIZE:-1024}
DOCKER_HOST=unix:///var/run/docker.sock

finish() {
	# Make all files owned by the build system
	chown -R "$USER_ID:$USER_GID" "${BUILD}"
}
trap finish EXIT

. /balena-api.inc

# Create user
echo "[INFO] Creating and setting $USER_ID:$USER_GID."
groupadd -g "$USER_GID" docker-disk-group || true
useradd -u "$USER_ID" -g "$USER_GID" -p "" docker-disk-user || true

mkdir -p $DATA_VOLUME/docker
mkdir -p $DATA_VOLUME/resin-data

touch $DATA_VOLUME/remove_me_to_reset

# Start docker
echo "Starting docker daemon with $BALENA_STORAGE storage driver."
dockerd -H "$DOCKER_HOST" --data-root="$DATA_VOLUME/docker" -s "$BALENA_STORAGE" -b none --experimental &
echo "Waiting for docker to become ready.."
STARTTIME="$(date +%s)"
ENDTIME="$STARTTIME"
while [ ! -S /var/run/docker.sock ]
do
    if [ $((ENDTIME - STARTTIME)) -le $DOCKER_TIMEOUT ]; then
        sleep 1 && ENDTIME=$((ENDTIME + 1))
    else
        echo "Timeout while waiting for docker to come up."
        exit 1
    fi
done
echo "Docker started."

# Authenticate with balena registry for private images
if [ -n "${HOSTEXT_IMAGES}" ] && [ -n "${BALENA_API_TOKEN}" ]; then
	balena_api_registry_login "${BALENA_API_ENV}" "${BALENA_API_TOKEN}" || true
fi

# Pull in host extension images via API resolution
BALENA_HOSTAPP_EXTENSIONS_LABEL="io.balena.image.class"
BALENA_HOSTAPP_EXTENSIONS_VALUE="overlay"
: > ${BUILD}/hostext-images
for ref in ${HOSTEXT_IMAGES}; do
	echo "Resolving ${ref}..."
	image_url=$(balena_api_resolve_fleet_image "${ref}" "${BALENA_API_ENV}" "${BALENA_API_TOKEN}")
	if [ -z "${image_url}" ]; then
		echo "Failed to resolve ${ref}"
		exit 1
	fi

	echo "Pulling ${image_url}..."
	if docker pull --platform "${HOSTAPP_PLATFORM}" "${image_url}"; then
		# Tag with sanitized reference for traceability (+ is invalid in Docker tags)
		tag=$(echo "${ref}" | tr '+' '_')
		docker tag "${image_url}" "${tag}"
		docker create --label "${BALENA_HOSTAPP_EXTENSIONS_LABEL}=${BALENA_HOSTAPP_EXTENSIONS_VALUE}" "${tag}" none
		echo "${image_url}" >> ${BUILD}/hostext-images
	else
		echo "Failed to pull ${ref}"
		exit 1
	fi
done

# Pull in the supervisor image as a separate app until it converges in the hostOS
if [ -n "${SUPERVISOR_FLEET}" ] && [ -n "${SUPERVISOR_VERSION}" ]; then
	_supervisor_image=$(balena_api_fetch_image_from_app "${SUPERVISOR_FLEET}" "${SUPERVISOR_VERSION#v}" "${BALENA_API_ENV}" "${BALENA_API_TOKEN}")
	echo "Pulling ${SUPERVISOR_FLEET}:${SUPERVISOR_VERSION}"
	if docker pull "${_supervisor_image}"; then
		docker tag "${_supervisor_image}" "${_supervisor_image%@*}"
		docker tag "${_supervisor_image}" "balena_supervisor":"${SUPERVISOR_VERSION}"
	else
		echo "Not able to pull ${_supervisor_image}"
		exit 1
	fi
fi

echo "Stopping docker..."
kill -TERM "$(cat /var/run/docker.pid)"
# don't let wait() error out and crash the build if the docker daemon has already been stopped
wait "$(cat /var/run/docker.pid)" || true

# Calculate partition size based on actual content
CONTENT_SIZE_MB=$(du -sm ${DATA_VOLUME} | awk '{print $1}')
# Add 20% padding for filesystem overhead, minimum 64 MB padding
PADDING_MB=$(( CONTENT_SIZE_MB / 5 ))
[ ${PADDING_MB} -lt 64 ] && PADDING_MB=64
CALCULATED_SIZE=$(( CONTENT_SIZE_MB + PADDING_MB ))

# Use larger of calculated size or configured PARTITION_SIZE
if [ ${CALCULATED_SIZE} -gt ${PARTITION_SIZE} ]; then
    echo "Auto-sizing partition: ${CONTENT_SIZE_MB} MB content + ${PADDING_MB} MB padding = ${CALCULATED_SIZE} MB"
    PARTITION_SIZE=${CALCULATED_SIZE}
else
    echo "Using configured partition size: ${PARTITION_SIZE} MB (content: ${CONTENT_SIZE_MB} MB)"
fi

# Export the final data filesystem
dd if=/dev/zero of=${BUILD}/resin-data.img bs=1M count=0 seek="${PARTITION_SIZE}"

# Usage type default, block size 4k defined in recipe. See https://github.com/tytso/e2fsprogs/issues/50
mkfs.ext4 -E lazy_itable_init=0,lazy_journal_init=0 -T default -b ${FS_BLOCK_SIZE}  -i 8192 -d ${DATA_VOLUME} -F ${BUILD}/resin-data.img
