DESCRIPTION = "The OCI Image Format project creates and maintains the software shipping container image format spec"
HOMEPAGE = "https://github.com/opencontainers/image-spec"
SECTION = "devel/go"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://src/${PKG_NAME}/LICENSE;md5=27ef03aa2da6e424307f102e8b42621d"

SRCNAME = "image-spec"

PKG_NAME = "github.com/opencontainers/${SRCNAME}"
SRC_URI = "git://${PKG_NAME}.git;destsuffix=git/src/${PKG_NAME};branch=main;protocol=https"

SRCREV = "54a822e528b91c8db63b873ad56daf200a2e5e61"
PV = "v1.0.1+git${SRCPV}"

S = "${WORKDIR}/git"

# NO-OP the do compile rule because this recipe is source only.
do_compile() {
}

do_install() {
	install -d ${D}${prefix}/local/go/src/${PKG_NAME}
	for j in $(cd ${S} && find src/${PKG_NAME} -name "*.go"); do
	    cp --parents $j ${D}${prefix}/local/go/
	done
	# .tool isn't useful, so remote it.
	rm -rf ${D}${prefix}/local/go/src/${PKG_NAME}/.tool/

	cp -r ${S}/src/${PKG_NAME}/LICENSE ${D}${prefix}/local/go/src/${PKG_NAME}/
}

SYSROOT_PREPROCESS_FUNCS += "image_spec_file_sysroot_preprocess"

image_spec_file_sysroot_preprocess () {
    install -d ${SYSROOT_DESTDIR}${prefix}/local/go/src/${PKG_NAME}
    cp -r ${D}${prefix}/local/go/src/${PKG_NAME} ${SYSROOT_DESTDIR}${prefix}/local/go/src/$(dirname ${PKG_NAME})
}

FILES:${PN} += "${prefix}/local/go/src/${PKG_NAME}/*"

CLEANBROKEN = "1"
