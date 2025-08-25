SUMMARY = "The libnss_ato module is a set of C library extensions which allows \
to map every nss request for unknown user to a single predefined user"
HOMEPAGE = "https://github.com/donapieppo/libnss-ato"
SECTION = "libs"

LICENSE = "LGPLv3"
LIC_FILES_CHKSUM = "file://copyright;md5=37e0ae856bc7cedaaaca1d4a681b62b0"

SRC_URI = " \
	git://github.com/donapieppo/libnss-ato;branch=master;protocol=https \
	file://0001-libnss_ato.c-Enable-use-for-root-user.patch \
"
SRCREV = "7f33780a09b3a6a256ff77601adaed28d9bb117a"
S = "${WORKDIR}/git"

do_compile() {
	oe_runmake 'CC=${CC}' all
}

do_install() {
	mkdir -p ${D}${libdir}
	mkdir -p ${D}${mandir}/man3
	oe_runmake 'prefix=${D}${prefix}' install

	mkdir -p ${D}${sysconfdir}
	echo "root:x:0:0:root:${ROOT_HOME}:/bin/sh" > ${D}${sysconfdir}/libnss-ato.conf
}

FILES:${PN}-dev = ""
FILES:${PN} += "${nonarch_libdir}/*.so"
