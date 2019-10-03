SUMMARY = "The libnss_ato module is a set of C library extensions which allows \
to map every nss request for unknown user to a single predefined user"
HOMEPAGE = "https://github.com/donapieppo/libnss-ato"
SECTION = "libs"

LICENSE = "LGPLv3"
LIC_FILES_CHKSUM = "file://copyright;md5=37e0ae856bc7cedaaaca1d4a681b62b0"

SRC_URI = " \
	git://github.com/donapieppo/libnss-ato \
	file://0001-libnss_ato.c-Enable-use-for-root-user.patch \
	file://libnss-ato.conf \
"
SRCREV = "4b4a77bd56113fdb6bff63bd851250b6ec029446"
S = "${WORKDIR}/git"

do_compile() {
	oe_runmake 'CC=${CC}' all
}

do_install() {
	mkdir -p ${D}${base_libdir}
	mkdir -p ${D}${mandir}/man3
	oe_runmake 'prefix=${D}' install

	mkdir -p ${D}${sysconfdir}
	install -m 0644 ${WORKDIR}/libnss-ato.conf ${D}${sysconfdir}
}

FILES_${PN} += "${base_libdir}/*.so"
FILES_${PN}-dev = ""
