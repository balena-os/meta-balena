DESCRIPTION = "A fast and low-memory footprint OCI Container Runtime fully written in C."
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"
PRIORITY = "optional"

SRCREV_crun = "718b94edc37e010a866d8b6b69ec0d30ada24613"
SRCREV_libocispec = "fb3c221d5849de9184f88b6929ce4a8c8fb55be9"
SRCREV_ispec = "54a822e528b91c8db63b873ad56daf200a2e5e61"
SRCREV_rspec = "ab23082b188344f6fbb63a441ea00ffc2852d06d"
SRCREV_yajl = "f344d21280c3e4094919fd318bc5ce75da91fc06"

SRCREV_FORMAT = "crun_rspec"
SRC_URI = "git://github.com/containers/crun.git;branch=main;name=crun;protocol=https \
           git://github.com/containers/libocispec.git;branch=main;name=libocispec;destsuffix=git/libocispec;protocol=https \
           git://github.com/opencontainers/runtime-spec.git;branch=main;name=rspec;destsuffix=git/libocispec/runtime-spec;protocol=https \
           git://github.com/opencontainers/image-spec.git;branch=main;name=ispec;destsuffix=git/libocispec/image-spec;protocol=https \
           git://github.com/containers/yajl.git;branch=main;name=yajl;destsuffix=git/libocispec/yajl;protocol=https \
          "

PV = "1.2+git${SRCREV_crun}"
S = "${WORKDIR}/git"

REQUIRED_DISTRO_FEATURES ?= "systemd"

inherit autotools-brokensep pkgconfig features_check

PACKAGECONFIG ??= ""

inherit features_check
REQUIRED_DISTRO_FEATURES ?= "seccomp"

DEPENDS = "yajl libcap go-md2man-native m4-native"
# TODO: is there a packageconfig to turn this off ?
DEPENDS += "libseccomp"
DEPENDS += "systemd"
DEPENDS += "oci-image-spec oci-runtime-spec"

do_configure:prepend () {
    # extracted from autogen.sh in crun source. This avoids
    # git submodule fetching.
    mkdir -p m4
    autoreconf -fi
}

do_install() {
    oe_runmake 'DESTDIR=${D}' install
}
