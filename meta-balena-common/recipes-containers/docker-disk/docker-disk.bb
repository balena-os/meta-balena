DESCRIPTION = "Docker data disk image"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
	file://Dockerfile \
	file://entry.sh \
	"

S = "${WORKDIR}"
B = "${S}/build"

inherit deploy
require docker-disk.inc
require recipes-containers/balena-supervisor/balena-supervisor.inc

PARTITION_SIZE ?= "192"
FS_BLOCK_SIZE ?= "4k"

PV = "${HOSTOS_VERSION}"

RDEPENDS:${PN} = "balena"

do_compile[network] = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile () {
	# Some sanity first
	if [ -z "${SUPERVISOR_FLEET}" ] || [ -z "${SUPERVISOR_VERSION}" ]; then
		bbfatal "docker-disk: SUPERVISOR_FLEET and/or SUPERVISOR_VERSION not set."
	fi
	if [ -z "${PARTITION_SIZE}" ]; then
		bbfatal "docker-disk: PARTITION_SIZE needs to have a value (megabytes)."
	fi

	# At this point we really need internet connectivity for building the
	# docker image
	if [ "x${@connected(d)}" != "xyes" ]; then
		bbfatal "docker-disk: Can't compile as there is no internet connectivity on this host."
	fi

	# We force the PATH to be the standard linux path in order to use the host's
	# docker daemon instead of the result of docker-native. This avoids version
	# mismatches
	DOCKER=$(PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" which docker)
	cp "${TOPDIR}/../balena-yocto-scripts/automation/include/balena-api.inc" "${WORKDIR}/"

	_token="${BALENA_API_TOKEN}"
	if [ -z "${_token}" ] && [ -f "~/.balena/token" ]; then
		_token=$(cat "~/.balena/token")
	fi

	# Generate the data filesystem
	RANDOM=$$
	_image_name="docker-disk-$RANDOM"
	_container_name="docker-disk-$RANDOM"
	$DOCKER rmi -f ${_image_name} > /dev/null 2>&1 || true
	$DOCKER build -t ${_image_name} -f ${WORKDIR}/Dockerfile ${WORKDIR}
	$DOCKER run --privileged --rm \
		-e BALENA_STORAGE=${BALENA_STORAGE} \
		-e USER_ID=$(id -u) -e USER_GID=$(id -u) \
		-e SUPERVISOR_FLEET="${SUPERVISOR_FLEET}" \
		-e SUPERVISOR_VERSION="${SUPERVISOR_VERSION}" \
		-e HOSTEXT_IMAGES="${HOSTEXT_IMAGES}" \
		-e HOSTAPP_PLATFORM="${HOSTAPP_PLATFORM}" \
		-e BALENA_API_ENV="${BALENA_API_ENV}" \
		-e BALENA_API_TOKEN="${_token}" \
		-e PARTITION_SIZE="${PARTITION_SIZE}" \
		-e FS_BLOCK_SIZE="${FS_BLOCK_SIZE}" \
		-v /sys/fs/cgroup:/sys/fs/cgroup:ro -v ${B}:/build \
		--name ${_container_name} ${_image_name}
	$DOCKER rmi -f ${_image_name}
}

do_install () {
	install -d ${D}${sysconfdir}
	for image in "${HOSTEXT_IMAGES}"; do
		echo "${image}" >> ${D}${sysconfdir}/hostapp-extensions.conf
	done
}

FILES:${PN} += "/etc/hostapp-extensions.conf"

do_deploy () {
	install -m 644 ${B}/resin-data.img ${DEPLOYDIR}/resin-data.img
}
addtask deploy before do_package after do_install

PACKAGE_ARCH = "${MACHINE_ARCH}"
