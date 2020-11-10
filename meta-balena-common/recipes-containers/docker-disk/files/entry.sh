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

source /balena-api.inc

update_apps_json() {
	local _appName
	local _appType
	local _api_env
	local _apps_json
	local _version
	local _variant
	local _commitID
	local _appID
	local _image_location
	local _svcID
	local _appUUID
	local _commitID
	local _imageId
	local _releaseId
	_appName="$1"
	_appType="$2"
	_version="$3"
	_variant="$4"
	_api_env="${BALENA_API_ENV}"
	_apps_json="${DATA_VOLUME}/apps.json"

	[ -z "${_appName}" ] && echo "Application name needs to be defined" && return 1
	[ -z "${_appType}" ] && echo "Type needs to be defined" && return 1
	[ -z "${_version}" ] && echo "Release version needs to be defined" && return 1
	[ -z "${_variant}" ] && echo "Release variant needs to be defined" && return 1

	_appID=$(print_appID_from_appName "${_appName}" "${_api_env}")
	if [ -n "${_appID}" ] && [ "${_appID}" != "null" ]; then
		_image_location=$(fetch_image_from_app "${_appName}" "${_version}" "${_api_env}" "${_variant}")
		[ -z "${_image_location}" ] && return 1
		_json=$(fetch_image_json "${_appName}" "${_api_env}" "${_version}" "${_variant}")
		_serviceName=$(echo "${_json}" | jq --raw-output '.d[0].is_part_of__release[0].release[0].composition.services' | jq 'keys[0]' | tr -d '"')
		_svcID=$(echo "${_json}" | jq --raw-output '.d[0].is_a_build_of__service.__id')
		_imageId=$(echo "${_json}" | jq --raw-output '.d[0].is_part_of__release[0].image.__id')
		_releaseId=$(echo "${_json}" | jq --raw-output '.d[0].is_part_of__release[0].id')
		_labels=$(echo "${_json}" | jq --raw-output ".d[0].is_part_of__release[0].release[0].composition.services.${_serviceName}.labels")
		_appUUID=$(print_appUUID_from_appName "${_appName}" "${_api_env}")
		_commitID=$(fetch_commitID_from_app "${_appName}" "${_version}" "${_api_env}" "${_variant}")
	else
		>&2 echo "[${_appName}] Application not found in ${_api_env}"
		return  1
	fi

	while read -r -d '' entry_json_app<<-EOF
{
   "${_appUUID}": {
		"commit": "${_commitID}",
		"releaseId": ${_releaseId},
		"appId": ${_appID},
		"name": "${_appName}",
		"type": "${_appType}",
		"services": {
		    "${_svcID}": {
			"serviceName": "${_serviceName}",
			"image": "${_image_location}",
			"imageId": ${_imageId},
			"environment": "{}",
			"labels": ${_labels}
		}
	}
}
}
EOF
	do
		# This avoid read returning error from not finding a newline termination
		:
	done

	if [ ! -f "${_apps_json}" ]; then
		while read -r -d '' template_apps_json<<-EOF
{
	"apps": {
}
}
EOF
		do
			# This avoid read returning error from not finding a newline termination
			:
		done
		echo "${template_apps_json}" > "${_apps_json}"
	fi

	tmpfile=$(mktemp)
	jq --argjson entry "${entry_json_app}" '.apps += $entry' "${_apps_json}" > "${tmpfile}"
	mv "${tmpfile}" "${_apps_json}"
}

balena_imageid_from_digest() {
        local _image="$1"
        local _digest
        local _image_name
        local _imageid
        local _digest_check
        _image_name=$(echo "${_image}" | cut -d "@" -f1)
        _digest=$(echo "${_image}" | cut -d "@" -f2)
        _imageid=$(docker images --filter=reference="${_image_name}" --format "{{.ID}}")
        _digest_check=$(docker images --digests --filter=reference="${_image_name}" --format "{{.Digest}}")
        if [ "${_digest}" == "${_digest_check}" ]; then
                echo "${_imageid}"
        fi
}

install_app() {
	local _appName="$1"
	local _appType="$2"
	local _release="$3"
	local _variant="$4"
	local _image_location
	local _api_env
	local _image_size
	local _image_size_bytes
	local _image_id
	echo "Pulling ${_appName} at ${_release} variant ${_variant}"
	_api_env=${BALENA_API_ENV}

	_image_location=$(fetch_image_from_app "${_appName}" "${_release}" "${_api_env}" "${_variant}")
	[ -z "${_image_location}" ] && echo "No image found for ${_release} variant ${_variant}" && return 1
	if docker pull --platform "${HOSTAPP_PLATFORM}" "${_image_location}"; then
		_image_id=$(balena_imageid_from_digest "${_image_location}")
		if [ "${_appType}" == "supervisor" ]; then
			docker tag "${_image_id}" "${SUPERVISOR_APP}:${SUPERVISOR_VERSION_LABEL}"
		elif [ "${_appType}" == "hostapp extension" ]; then
			local _tag
			_tag=${_release}
			if [ -n "${_variant}" ]; then
				_tag="${_tag}.${_variant}"
			fi
			docker tag "${_image_id}" "${_appName}:${_tag}"
		fi
		# Adjust PARTITION_SIZE
		_image_size_bytes=$(fetch_size_from_app "${_appName}" "${_release}" "${_api_env}" "${_variant}")
		MB_TO_BYTES=$(( 1024*1024 ))
		_image_size_bytes=$(( PARTITION_SIZE*MB_TO_BYTES + _image_size_bytes ))
		PARTITION_SIZE=$(( _image_size_bytes/MB_TO_BYTES ))
		if ! update_apps_json "${_appName}" "${_appType}" "${_release}" "${_variant}"; then
			echo "Generation of apps.json failed"
			exit 1
		fi
	else
		echo "Not able to pull ${_appName} for ${HOSTAPP_PLATFORM}"
		exit 1
	fi
}

# Create user
echo "[INFO] Creating and setting $USER_ID:$USER_GID."
groupadd -g "$USER_GID" docker-disk-group || true
useradd -u "$USER_ID" -g "$USER_GID" -p "" docker-disk-user || true

mkdir -p $DATA_VOLUME/docker
mkdir -p $DATA_VOLUME/resin-data

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

# Pull in the supervisor image
if [ -n "${SUPERVISOR_APP}" ] && [ -n "${SUPERVISOR_VERSION_LABEL}" ]; then
	install_app "${SUPERVISOR_APP}" "supervisor" "${SUPERVISOR_VERSION_LABEL}" "none"
fi

# Pull in arch specific hello-world image and tag it balena-healthcheck-image
echo "Pulling ${HELLO_REPOSITORY}:latest..."
docker pull --platform "${HOSTAPP_PLATFORM}" "${HELLO_REPOSITORY}"
docker tag "${HELLO_REPOSITORY}" balena-healthcheck-image
docker rmi "${HELLO_REPOSITORY}"
docker save balena-healthcheck-image > ${BUILD}/balena-healthcheck-image.tar
# Pull in host extension images, both space-separated or colon-separated lists are accepted
for image_name in $(echo ${HOSTEXT_IMAGES} | tr ":" " "); do
	install_app "${image_name}" "hostapp extension" "$(echo ${HOSTOS_VERSION} | tr "+" "_")" "${VARIANT}"
done

echo "Stopping docker..."
kill -TERM "$(cat /var/run/docker.pid)"
# don't let wait() error out and crash the build if the docker daemon has already been stopped
wait "$(cat /var/run/docker.pid)" || true

# Export the apps.json meta-data
cp "${DATA_VOLUME}/apps.json" "${BUILD}"/

# Export the final data filesystem
dd if=/dev/zero of=${BUILD}/resin-data.img bs=1M count=0 seek="${PARTITION_SIZE}"

# Usage type default, block size 4k defined in recipe. See https://github.com/tytso/e2fsprogs/issues/50
mkfs.ext4 -E lazy_itable_init=0,lazy_journal_init=0 -T default -b ${FS_BLOCK_SIZE}  -i 8192 -d ${DATA_VOLUME} -F ${BUILD}/resin-data.img
