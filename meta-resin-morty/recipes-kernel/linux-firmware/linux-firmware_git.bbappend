FILESEXTRAPATHS_append := ":${THISDIR}/files"

SRC_URI_append = " \
    file://0001-Revert-rt2870sta-Update-rt3071.bin-to-match-rt2870.b.patch \
    file://0002-Revert-linux-firmware-update-rt2870.bin-rt2800usb-dr.patch \
"

LIC_FILES_CHKSUM_remove = " file://WHENCE;md5=f514a0c53c5d73c2fe98d5861103f0c6"
LIC_FILES_CHKSUM_append = " file://WHENCE;md5=64134282232eb967c0d48e52048967cc"

do_patch () {
    cd ${S}
    git apply ${WORKDIR}/0001-Revert-rt2870sta-Update-rt3071.bin-to-match-rt2870.b.patch
    git apply ${WORKDIR}/0002-Revert-linux-firmware-update-rt2870.bin-rt2800usb-dr.patch
}
