FILESEXTRAPATHS_append := ":${THISDIR}/files"

python() {
	from distutils.version import StrictVersion
	packageVersion = d.getVar('PV', True)
	srcURI = d.getVar('SRC_URI', True)
	if StrictVersion(packageVersion) >= StrictVersion('2.28'):
		d.setVar('SRC_URI', srcURI + ' ' + 'file://0001-libblkid-don-t-check-for-size-on-UBI-char-dev.patch')
}

PACKAGES =+ "util-linux-lsblk"
FILES_util-linux-lsblk = "${bindir}/lsblk"
