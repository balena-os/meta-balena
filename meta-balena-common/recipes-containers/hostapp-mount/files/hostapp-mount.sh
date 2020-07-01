#!/bin/bash

set -o pipefail

shopt -s extglob

hostapp_mount_help() {
	cat << EOF
Script to mount hostapp overlays directories over root filesystem.
$0 <OPTION>

Options:
  -m, --mount
        Mount overlays
  -u, --umount
        Umount overlays
  -h, --help
        Display this help and exit
EOF
}

while [ $# -gt 0 ]; do
	arg="$1"

	case $arg in
		-h|--help)
			hostapp_mount_help
			exit 0
			;;
		-m|--mount)
			action="mount"
			;;
		-u|--umount)
			action="umount"
			;;
		*)
			echo "ERROR: Unrecognized option $1."
			exit 1
			;;
	esac
	shift
done

# shellcheck disable=SC1091
. /usr/sbin/resin-vars

# Detect containers engine
if which docker > /dev/null 2>&1; then
    DOCKER=docker
elif which rce > /dev/null 2>&1; then
    DOCKER=rce
elif which balena > /dev/null 2>&1; then
    DOCKER=balena
else
    echo "ERROR: No container engine detected."
    error_handler "no container engine detected"
fi

# Overlay a given directory
# Arguments:
# 1 - Path to the overlay mount root
# 2 - Path to the directory to build relative to the overlay mount root above
overlay_dir() {
	overlay_mnt="${1}"
	dir=${2}
	mkdir -p "${dir}"
	mount -t overlay overlay -o  lowerdir="${dir}:${overlay_mnt}/${dir}" "${dir}"
	if [ "$?" ]; then
		echo "Overlayed ${dir}"
	else
		echo "[ERROR]: Failed to overlay ${dir}"
		return 1
	fi
}

# Mount directories from a mounted overlay container filesystem
# Read-write mounting is not allowed as the upperdir is also an overlay fs.
# See https://lkml.org/lkml/2018/1/8/81
# Arguments:
# 1 - Path to the overlay mount
mount_layer() {
	OVERLAY_MOUNT="$1"
	last_overlayed_dir="None"
	find "${OVERLAY_MOUNT}" -type d -print0 | while read -r -d '' dir
	do
		# Skip empty directories
		if [ ! "$(ls -A ${dir})" ]; then echo "Skipping empty ${dir##*merged}";  continue; fi
		opath=$(echo "${dir##*merged}")
		[ -z "${opath}" ] && continue
		rootdir=$(dirname "${opath}")
		case "${rootdir}" in
			# Protected directories
			/dev|/proc|/sys|/mnt|/run|/tmp|/resin-*) echo "Skipping ${rootdir}, blacklist match" && continue;;
			*)
				if grep "ext4\|overlay" /proc/mounts | grep "${opath}" | grep "rw" > /dev/null; then
					echo "Shadowing rw mounted directories not allowwed - traversing ${opath}"
					continue
				else
					case ${opath} in
						# Skip if parent directory has just been recursively overlayed
						${last_overlayed_dir}/*) continue ;;
						*)
							if ! overlay_dir "${OVERLAY_MOUNT}" "${opath}"; then
								return 1
							fi
							;;
					esac
					last_overlayed_dir="${opath}"
				fi
				;;
		esac
	done
}

# Unmount all directories from overlay mount
# Arguments:
# 1 - Path to the overlay mount
umount_layer() {
	overlay_mnt="${1}"
	grep "overlay" /proc/mounts | grep "${overlay_mnt}" | while IFS= read -r line; do
		dir=$(echo "${line}" | cut -d " " -f2)
		if [ -d "${dir}" ] && umount -l "${dir}"; then
			echo "Unmounted ${dir}"
		fi
	done
}

# Locate container images
# Right now it uses a running balena engine, in future it will use a minimal tool to find images
# Arguments:
# 1 - Container image name
# Returns:
# 0 - Success, overlay mount path in stdout
# 1 - Error
find_image () {
	image_name="$1"
	image_id=$(${DOCKER} images -q "${image_name}")
	if [ -z "${image_id}" ]; then
		echo "Failed to find ${image_name}"
		return 1
	fi
	cid=$(${DOCKER} ps -a -q --no-trunc --filter ancestor="${image_name}")
	if [ -z "${cid}" ]; then
		cid=$(${DOCKER} create --runtime="bare" "${image_id}" /bin/fail)
	fi
	if [ -z "${cid}" ]; then echo "Failed to find hostapp container"; exit 1; fi
	overlay_mount=$(/usr/bin/hostapp-mount --dataroot /mnt/data/docker --container-id "${cid}")
	if [ -z "${overlay_mount}" ]; then echo "Failed to mount container filesystem"; exit 1; fi
	echo "${overlay_mount}"
}

if [ -z "${HOSTAPP_IMAGES}" ]; then
	HOSTAPP_IMAGES=$(cat /etc/hostapp-images.conf)
fi
[ -z "${action}" ] && echo "No action provided" && exit 0
for image in ${HOSTAPP_IMAGES}; do
	if overlay_mount=$(find_image "${image}"); then
		case "${action}" in
			mount)
				echo "Mounting overlays directories from ${image}"
				mount_layer "${overlay_mount}"
				;;
			umount)
				echo "Umounting overlays directories from ${image}"
				umount_layer "${overlay_mount}"
				;;
			*)
				echo "Unknown action ${action}"
				exit 1
				;;
		esac
	fi
done
