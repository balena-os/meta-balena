#!/bin/bash

CURL="curl -s"

TRANSLATION=${TRANSLATION:-"v6"}

DEBUG=0
pp_json() {
	if [ "${DEBUG}" = "1" ]; then
		echo "${1}" | >&2 jq .
	fi
}

dlog() {
	if [ "${DEBUG}" = "1" ]; then
		>&2 echo "${1}"
	fi
}

# Returns success if the check fails
check_fail() {
	local _json
	local _msg
	_json="$1"
	_msg="$2"

	if [ "${_json}" != "OK" ]; then
		pp_json "${_json}"
		>&2 echo "${_msg}"
		return 0
	fi
	return 1
}

# Print public application ID from application name
# Arguments:
#
# $1: Application name
# $2: Balena target environment
#
# Result:
# Prints the application ID or null if it does not exist
print_appID_from_appName() {
	local _appName="$1"
	local _apiEnv="$2"
	[ -z "${_appName}" ] && >&2 echo "Application name is required" && return 1
	local _appID=""
	local _json=""
        local _admin=${BALENA_ADMIN:-balena_os}
	_json=$(${CURL} -XGET "https://api.${_apiEnv}/${TRANSLATION}/application?\$filter=(slug%20eq%20'${_admin}/${_appName}')" -H "Content-Type: application/json")
	pp_json "${_json}"
	_appID=$(echo "${_json}" | jq --raw-output '.d[0].id')
	dlog "[${_appName}] Application ID is ${_appID}"
	echo "${_appID}"
}

# Print UUID from public application name
# Arguments:
#
# $1: Application name
# $2: Balena target environment
#
# Result:
# Prints the application UUID or null if it does not exist
print_appUUID_from_appName() {
	local _appName="$1"
	local _apiEnv="$2"
	[ -z "${_appName}" ] && >&2 echo "Application name is required" && return 1
	local _appUUID=""
	local _json=""
        local _admin=${BALENA_ADMIN:-balena_os}
	_json=$(${CURL} -XGET "https://api.${_apiEnv}/${TRANSLATION}/application?\$filter=(slug%20eq%20'${_admin}/${_appName}')" -H "Content-Type: application/json")
	pp_json "${_json}"
	_appUUID=$(echo "${_json}" | jq --raw-output ".d[0].uuid")
	dlog "[${_appName}] Application UUID is ${_appUUID}"
	echo "${_appUUID}"
}

# Count all releases at a specific version and optional variant
# Arguments:
#
# $1: Public application name
# $2: Balena target environment
# $3: Release version label
# $4: Release variant label
#
# Result:
# Prints the releases count metadata in JSON format
count_releases_json() {
	local _appName="$1"
	local _apiEnv="$2"
	local _version="$3"
	local _variant="$4"
	local _json=""
	local _selector=""
	local _selector_version=""
	local _selector_variant=""

	# Get application ID from application name
	_appID=$(print_appID_from_appName "${_appName}" "${_apiEnv}")

	_selector_version="%20and%20(release_tag/any(rt:(rt/tag_key%20eq%20'version')%20and%20(rt/value%20eq%20%27${_version}%27)))"
	_selector_variant="%20and%20(release_tag/any(rt:(rt/tag_key%20eq%20'variant')%20and%20(rt/value%20eq%20%27${_variant}%27)))"
	if [ -n "${_version}" ]; then
		_selector="${_selector_version}"
	fi
	if [ "${_variant}" != "none" ]; then
		_selector="${_selector}${_selector_variant}"
	fi

	_json=$(${CURL} -XGET -H "Content-Type: application/json" "https://api.${_apiEnv}/${TRANSLATION}/release/\$count?\$filter=(belongs_to__application%20eq%20${_appID})${_selector}")
	pp_json "${_json}"
	echo "${_json}"
}

# Fetch all releases at a specific version and optional variant in chronologically descending order (most recent first)
# Arguments:
#
# $1: Public application name
# $2: Balena target environment
# $3: Release version label
# $4: Release variant label
#
# Result:
# Prints the releases metadata in JSON format
fetch_releases_json() {
	local _appName="$1"
	local _apiEnv="$2"
	local _version="$3"
	local _variant="$4"
	local _json=""
	local _selector=""
	local _selector_version=""
	local _selector_variant=""

	# Get application ID from application name
	_appID=$(print_appID_from_appName "${_appName}" "${_apiEnv}")

	_selector_version="%20and%20(release_tag/any(rt:(rt/tag_key%20eq%20'version')%20and%20(rt/value%20eq%20%27${_version}%27)))"
	_selector_variant="%20and%20(release_tag/any(rt:(rt/tag_key%20eq%20'variant')%20and%20(rt/value%20eq%20%27${_variant}%27)))"
	if [ -n "${_version}" ]; then
		_selector="${_selector_version}"
	fi
	if [ "${_variant}" != "none" ]; then
		_selector="${_selector}${_selector_variant}"
	fi
	_json=$(${CURL} -XGET -H "Content-Type: application/json" "https://api.${_apiEnv}/${TRANSLATION}/release?\$filter=(belongs_to__application%20eq%20${_appID})${_selector}&\$orderby=created_at%20desc")
	pp_json "${_json}"
	echo "${_json}"
}

# Fetch image location for a specific release
# Arguments:
#
# $1: Application name
# $2: Balena target environment
# $3: BalenaOS version
# $4: BalenaOS variant
#
# Result:
# Prints the releases metadata in JSON format
fetch_image_json() {
	local _appName="$1"
	local _apiEnv="$2"
	local _version="$3"
	local _variant="$4"
	local _json=""
	local _dbID

	_dbID=$(get_dbid_from_app_name "${_appName}" "${_version}" "${_apiEnv}" "${_variant}")

	_json=$(${CURL} -XGET "https://api.${_apiEnv}/${TRANSLATION}/image?%24expand=is_part_of__release(%24expand=release)&%24filter=is_part_of__release/release%20eq%20${_dbID}" -H "Content-Type:application/json")
	pp_json "${_json}"
	echo "${_json}"
}

# Get release database ID from public application name for a specific release and optional variant
# Arguments:
#
# $1: Application name
# $2: Release version label
# $3: Balena API environment
# $4: Release  variant label
#
# Result:
# Prints the release database ID in stdout
get_dbid_from_app_name() {
	local _appName="${1}"
	local _version="${2}"
	local _apiEnv="${3}"
	local _variant="${4}"
	local _appID=""
	local _count=""
	local _dbID=""

	dlog "[get_dbid_from_app_name] Fetching images from ${_appName}, OS release ${_version} variant ${_variant}"

	# Count the number of releases for specified version and variant tags
	_count=$(count_releases_json "${_appName}" "${_apiEnv}" "${_version}" "${_variant}" | jq --raw-output '.d')
	[ "${_count}" = "0" ] && >&2 echo "[${_appName}]: No release found for ${_version} ${_variant}" && return 1
	if [ "${_count}" -gt "1" ]; then
		>&2 echo "[${_appName}]: Hit a total of ${_count} releases for ${_version} variant ${_variant} - using most recent"
	fi

	# Fetch release database identifier from application with specified version and variant tags
	_dbID=$(fetch_releases_json "${_appName}" "${_apiEnv}" "${_version}" "${_variant}" | jq --raw-output '.d[0].id')
	echo "${_dbID}"
}

# Get release commit ID from public application name for a specific release and optional variant
# Arguments:
#
# $1: Application name
# $2: Release version label
# $3: Balena API environment
# $4: Release  variant label
#
# Result:
# Prints the release database ID in stdout
fetch_commitID_from_app() {
	local _appName="${1}"
	local _version="${2}"
	local _apiEnv="${3}"
	local _variant="${4}"
	local _commitID=""

	dlog "[fetch_commitID_from_app] Fetching images from ${_appName}, OS release ${_version} variant ${_variant}"

	# Fetch release commitID from application with specified version and variant tags
	_commitID=$(fetch_releases_json "${_appName}" "${_apiEnv}" "${_version}" "${_variant}" | jq --raw-output '.d[0].commit')
	echo "${_commitID}"
}

# Get image size from a public application name for a specific release and optional variant
# Arguments:
#
# $1: Application name
# $2: Release version label
# $3: Balena API environment
# $4: Release variant label if applicable
#
# Result:
# Prints the image size in stdout
fetch_size_from_app() {
	local _appName="${1}"
	local _version="${2}"
	local _apiEnv="${3}"
	local _variant="${4}"
	local _imageSize=""
	local _json=""

	_json=$(fetch_image_json "${_appName}" "${_apiEnv}" "${_version}" "${_variant}")
	_imageSize=$(echo "${_json}" | jq  --raw-output '.d[0].image_size')
	dlog "Image size is ${_imageSize}"
	echo "${_imageSize}"
}

# Get image registry location from a public application name for a specific release and optional variant
# Arguments:
#
# $1: Application name
# $2: Release version label
# $3: Balena API environment
# $4: Release variant label
#
# Result:
# Prints the image location in stdout
fetch_image_from_app() {
	local _appName="${1}"
	local _version="${2}"
	local _apiEnv="${3}"
	local _variant="${4}"
	local _imageLocation=""
	local _imageDigest=""
	local _json=""

	_json=$(fetch_image_json "${_appName}" "${_apiEnv}" "${_version}" "${_variant}")

	# Get locations for image associated with it
	_imageLocation=$(echo "${_json}" | jq --raw-output '.d[0].is_stored_at__image_location')
	_imageDigest=$(echo "${_json}" | jq  --raw-output '.d[0].content_hash')

	dlog "Image is ${_imageLocation}@${_imageDigest}"
	echo "${_imageLocation}@${_imageDigest}"
}

# Update an apps.json file with metadata about preloaded apps
# Arguments:
#
# $1: Application name
# $2: Application type (supervisor|supervised|hostapp extension)
# $3: Release version label
# $4: Release variant label (none if unused)
#
# Result:
# Updates apps.json in $DATA_VOLUME
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
		_serviceName=$(echo "${_json}" | jq --raw-output '.d[0].is_part_of__release[0].release[0].composition.services | keys[0]')
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
			"environment": {},
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
