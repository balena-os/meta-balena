DESCRIPTION = "A fast and low-memory footprint OCI Container Runtime fully written in C."
LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"
PRIORITY = "optional"

SRCREV_crun = "4a9b272b98768549da1277ec073c66c3ef51fd5b"
SRCREV_libocispec = "450147a59c83ddc0e31adc5031c260c08010daba"
SRCREV_ispec = "775207bd45b6cb8153ce218cc59351799217451f"
SRCREV_rspec = "020fda7ff619ad128da9c07062ed03b4bde1f868"

SRCREV_FORMAT = "crun_rspec"
SRC_URI = "git://github.com/containers/crun.git;branch=master;name=crun \
           git://github.com/containers/libocispec.git;branch=master;name=libocispec;destsuffix=git/libocispec \
           git://github.com/opencontainers/runtime-spec.git;branch=master;name=rspec;destsuffix=git/libocispec/runtime-spec \
           git://github.com/opencontainers/image-spec.git;branch=master;name=ispec;destsuffix=git/libocispec/image-spec \
	   file://0001-seccomp-allow-compiling-without-libseccomp.patch \
          "

PV = "0.10.2+git${SRCREV_crun}"
S = "${WORKDIR}/git"

inherit autotools-brokensep pkgconfig

PACKAGECONFIG ??= "caps \
                   ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', '', d)}"

PACKAGECONFIG[seccomp] = ",--disable-seccomp,libseccomp"
PACKAGECONFIG[caps] = ",--disable-caps,libcap"
PACKAGECONFIG[bpf] = ",--disable-bpf,"
PACKAGECONFIG[python] = "--with-python-bindings,,"
PACKAGECONFIG[man] = ",,go-md2man-native"
PACKAGECONFIG[systemd] = ",--disable-systemd,systemd"

DEPENDS = "yajl"

do_install() {
    oe_runmake 'DESTDIR=${D}' install
}
