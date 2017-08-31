require recipes-devtools/go/go-common.inc

# Fix LICENSE
LIC_FILES_CHKSUM = "file://${WORKDIR}/go-${PV}/go/LICENSE;md5=5d4950ecb7b26d2c5e4e7b4e0dd74707"

GO_TAG = "1_7"

SRC_URI = "${SRC_URI_PREFIX}/go${PV}.src.tar.gz;name=go_${GO_TAG};subdir=go-${PV}"
SRC_URI[go_1_7.md5sum] = "83d1b7bd4281479ab7d153e5152c9fc9"
SRC_URI[go_1_7.sha256sum] = "79430a0027a09b0b3ad57e214c4c1acfdd7af290961dd08d322818895af1ef44"

SRC_URI += " \
    file://fix-cross-compilation.patch \
    file://0001-runtime-assume-64kB-physical-pages-on-ARM.patch \
    file://0002-runtime-fetch-physical-page-size-from-the-OS.patch \
    file://0003-runtime-insufficient-padding-in-the-p-structure.patch \
    file://0004-runtime-don-t-hard-code-physical-page-size.patch \
    file://0005-syscall-make-Getpagesize-return-page-size-from-runti.patch \
    file://0006-runtime-debug-enable-TestFreeOSMemory-on-all-arches.patch \
"
