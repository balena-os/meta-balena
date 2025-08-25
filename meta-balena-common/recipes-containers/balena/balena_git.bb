HOMEPAGE = "https://www.balena.io/"
SUMMARY = "A Moby-based container engine for IoT"
DESCRIPTION = "Balena is a new container engine purpose-built for embedded \
and IoT use cases and compatible with Docker containers. Based on Docker’s \
Moby Project, balena supports container deltas for 10-70x more efficient \
bandwidth usage, has 3.5x smaller binaries, uses RAM and storage more \
conservatively, and focuses on atomicity and durability of container \
pulling."
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://src/import/LICENSE;md5=4859e97a9c7780e77972d989f0823f28"

inherit systemd
inherit go
inherit goarch
inherit pkgconfig
inherit useradd

BALENA_VERSION = "v20.10.43"
BALENA_BRANCH = "master"

SRCREV = "0be8046a1c191ad789a65d7d8429d899d6bc9fbe"
# NOTE: update patches when bumping major versions
# [0] will have up-to-date versions, make sure poky version matches what
# meta-balena uses
#
# 0: https://git.yoctoproject.org/meta-virtualization/tree/recipes-containers/docker/files
SRC_URI = "\
	git://github.com/balena-os/balena-engine.git;branch=${BALENA_BRANCH};destsuffix=git/src/import;protocol=https \
	file://balena.service \
	file://balena-host.service \
	file://balena-host.socket \
	file://balena-healthcheck \
	file://var-lib-docker.mount \
	file://balena.conf.storagemigration \
	file://balena-tmpfiles.conf \
	file://0001-dynbinary-use-go-cross-compiler.patch \
	"
S = "${WORKDIR}/git"

CVE_PRODUCT = "balena:balena-engine mobyproject:moby"

CVE_STATUS[CVE-2024-21626] = "backported-patch: runc has been updated to a non-vulnerable version"
CVE_STATUS[CVE-2023-28840] = "not-applicable-config: Swarm Mode is not part of balena-engine"
CVE_STATUS[CVE-2023-28841] = "not-applicable-config: Swarm Mode is not part of balena-engine"
CVE_STATUS[CVE-2023-28842] = "not-applicable-config: Swarm Mode is not part of balena-engine"
CVE_STATUS[CVE-2024-23650] = "not-applicable-config: Buildkit is not part of balena-engine"
CVE_STATUS[CVE-2024-23651] = "not-applicable-config: Buildkit is not part of balena-engine"
CVE_STATUS[CVE-2024-23652] = "not-applicable-config: Buildkit is not part of balena-engine"
CVE_STATUS[CVE-2024-23653] = "not-applicable-config: Buildkit is not part of balena-engine"
CVE_STATUS[CVE-2024-32473] = "not-applicable-config: balena-engine doesn't support ipvlan or macvlan"
CVE_STATUS[CVE-2024-41110] = "not-applicable-config: balena-engine doesn't use an AuthZ plugin"

PV = "${@d.getVar('BALENA_VERSION').replace('v', '')}+git${SRCREV}"

SECURITY_CFLAGS = "${SECURITY_NOPIE_CFLAGS}"
SECURITY_LDFLAGS = ""

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE:${PN} = "balena.service balena-host.socket var-lib-docker.mount"
GO_IMPORT = "import"
USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = "-r balena-engine"

DEPENDS:append:class-target = " systemd"
RDEPENDS:${PN}:class-target = "curl util-linux iptables tini systemd healthdog bash procps-ps"
RRECOMMENDS:${PN}:class-target += "kernel-module-nf-nat"

# oe-meta-go recipes try to build go-cross-native
DEPENDS:remove:class-native = "go-cross-native"
DEPENDS:append:class-native = " go-native"

INSANE_SKIP:${PN} += "already-stripped"

FILES:${PN} += " \
	${systemd_unitdir}/system/* \
	${ROOT_HOME} \
	${localstatedir} \
	"

DOCKER_PKG="github.com/docker/docker"
BUILD_TAGS="no_btrfs no_cri no_devmapper no_zfs exclude_disk_quota exclude_graphdriver_btrfs exclude_graphdriver_devicemapper exclude_graphdriver_zfs"

do_configure[noexec] = "1"

do_compile() {
	# Set GOPATH. See 'PACKAGERS.md'. Don't rely on
	# docker to download its dependencies but rather
	# use dependencies packaged independently.
	cd ${S}/src/import
	rm -rf .gopath
	mkdir -p .gopath/src/"$(dirname "${DOCKER_PKG}")"
	ln -sf ../../../.. .gopath/src/"${DOCKER_PKG}"

	export GOPATH="${S}/src/import/.gopath:${S}/src/import/vendor:${STAGING_DIR_TARGET}/${prefix}/local/go"
	export GOROOT="${STAGING_DIR_NATIVE}/${nonarch_libdir}/${HOST_SYS}/go"

	# Pass the needed cflags/ldflags so that cgo
	# can find the needed headers files and libraries
	export GOARCH=${TARGET_GOARCH}
	export CGO_ENABLED="1"
	export CGO_CFLAGS="${CFLAGS} --sysroot=${STAGING_DIR_TARGET}"
	export CGO_LDFLAGS="${LDFLAGS} --sysroot=${STAGING_DIR_TARGET}"
	export DOCKER_BUILDTAGS="${BUILD_TAGS} ${PACKAGECONFIG_CONFARGS}"
	export DOCKER_LDFLAGS="-s"
	export GO111MODULE=off

	export DISABLE_WARN_OUTSIDE_CONTAINER=1

	VERSION=${BALENA_VERSION} DOCKER_GITCOMMIT="${SRCREV}" ./hack/make.sh dynbinary
}

do_install() {
	root_bindmount_name=$(echo "${ROOT_HOME}" | sed 's|/|-|g')
	mkdir -p ${D}/${bindir}
	install -m 0755 ${S}/src/import/bundles/dynbinary-daemon/balena-engine ${D}/${bindir}/balena-engine

	ln -sf balena-engine ${D}/${bindir}/balena
	ln -sf balena-engine ${D}/${bindir}/balenad
	ln -sf balena-engine ${D}/${bindir}/balena-containerd
	ln -sf balena-engine ${D}/${bindir}/balena-containerd-shim-runc-v2
	ln -sf balena-engine ${D}/${bindir}/balena-containerd-ctr
	ln -sf balena-engine ${D}/${bindir}/balena-runc
	ln -sf balena-engine ${D}/${bindir}/balena-proxy

	ln -sf balena-engine ${D}/${bindir}/balena-engine-daemon
	ln -sf balena-engine ${D}/${bindir}/balena-engine-containerd
	ln -sf balena-engine ${D}/${bindir}/balena-engine-containerd-ctr
	ln -sf balena-engine ${D}/${bindir}/balena-engine-runc
	ln -sf balena-engine ${D}/${bindir}/balena-engine-proxy

	install -d ${D}${systemd_unitdir}/system
	install -m 0644 ${S}/src/import/contrib/init/systemd/balena-engine.socket ${D}/${systemd_unitdir}/system

	install -m 0644 ${WORKDIR}/balena.service ${D}/${systemd_unitdir}/system

	sed -i -e "s,@ROOT_HOME@,${root_bindmount_name},g" ${D}/${systemd_unitdir}/system/balena.service
	install -m 0644 ${WORKDIR}/balena-host.service ${D}/${systemd_unitdir}/system
	install -m 0644 ${WORKDIR}/balena-host.socket ${D}/${systemd_unitdir}/system

	install -m 0644 ${WORKDIR}/var-lib-docker.mount ${D}/${systemd_unitdir}/system

	mkdir -p ${D}/usr/lib/balena
	install -m 0755 ${WORKDIR}/balena-healthcheck ${D}/usr/lib/balena/balena-healthcheck

	install -d ${D}${sysconfdir}/systemd/system/balena.service.d
	install -c -m 0644 ${WORKDIR}/balena.conf.storagemigration ${D}${sysconfdir}/systemd/system/balena.service.d/storagemigration.conf

	install -d ${D}/${ROOT_HOME}/.docker
	ln -sf .docker ${D}/${ROOT_HOME}/.balena
	ln -sf .docker ${D}/${ROOT_HOME}/.balena-engine

	install -d ${D}${localstatedir}/lib/docker
	ln -sf docker ${D}${localstatedir}/lib/balena
	ln -sf docker ${D}${localstatedir}/lib/balena-engine

	install -d ${D}${sysconfdir}/tmpfiles.d
	install -m 0644 ${WORKDIR}/balena-tmpfiles.conf ${D}${sysconfdir}/tmpfiles.d/
}

BBCLASSEXTEND = " native"
