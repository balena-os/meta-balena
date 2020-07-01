HOMEPAGE = "https://www.balena.io/"
SUMMARY = "Utility to mount container filesystems"
DESCRIPTION = "Utility to mount container filesystems"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit go

DEPENDS += "go-dep-native bash"
RDEPENDS_${PN} += " \
    bash \
    balena \
    resin-vars \
    "

SRC_URI = "\
    file://main.go;subdir=build/src/hostapp-mount \
    file://hostapp-mount.service \
    file://hostapp-mount.sh \
"
S = "${WORKDIR}/build/src/hostapp-mount"

inherit systemd

SYSTEMD_SERVICE_${PN} = "hostapp-mount.service"

do_configure() {
    cd ${GOPATH}/src/hostapp-mount
    rm -rf Gopkg.toml Gopkg.lock
    dep init
    dep ensure
}

do_compile() {
	# Pass the needed cflags/ldflags so that cgo
	# can find the needed headers files and libraries
	export CFLAGS=""
	export LDFLAGS=""
	export CGO_CFLAGS="${CFLAGS} --sysroot=${STAGING_DIR_TARGET}"
	export CGO_LDFLAGS="${LDFLAGS}  --sysroot=${STAGING_DIR_TARGET}"

        cd ${GOPATH}/src/hostapp-mount
	#go build -ldflags '-extldflags "-static"' -o hostapp-mount .
	go build -o hostapp-mount .
}

do_install() {
	install -d ${D}${bindir}
        install -m 0755 ${GOPATH}/src/hostapp-mount/hostapp-mount ${D}${bindir}/
        install -m 0755 ${WORKDIR}/hostapp-mount.sh ${D}${bindir}/

        if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
            install -d ${D}${systemd_unitdir}/system
            install -c -m 0644 ${WORKDIR}/hostapp-mount.service ${D}${systemd_unitdir}/system
            sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
                -e 's,@SBINDIR@,${sbindir},g' \
                -e 's,@BINDIR@,${bindir},g' \
                ${D}${systemd_unitdir}/system/*.service
        fi
}

FILES_${PN} += " \
    ${bindir}/hostapp-mount \
"
