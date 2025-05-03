
RUST_ALTERNATE_EXE_PATH = "${STAGING_LIBDIR_NATIVE}/llvm-rust/bin/llvm-config"

require rust.inc

DEPENDS += "rust-llvm (=${PV})"

inherit cross-canadian

DEPENDS += "  \
            virtual/${HOST_PREFIX}gcc-crosssdk \
            virtual/nativesdk-libc rust-llvm-native \
            virtual/${TARGET_PREFIX}compilerlibs \
            virtual/nativesdk-${HOST_PREFIX}compilerlibs \
            gcc-cross-${TARGET_ARCH} \
           "

# The host tools are likely not to be able to do the necessary operation on
# the target architecturea. Alternatively one could check compatibility
# between host/target.
EXCLUDE_FROM_SHLIBS_${RUSTLIB_TARGET_PN} = "1"

DEBUG_PREFIX_MAP = "-fdebug-prefix-map=${WORKDIR}=/usr/src/debug/${PN}/${EXTENDPE}${PV}-${PR} \
                    -fdebug-prefix-map=${STAGING_DIR_HOST}= \
                    -fdebug-prefix-map=${STAGING_DIR_NATIVE}= \
                    "

python do_rust_gen_targets () {
    wd = d.getVar('WORKDIR') + '/targets/'
    # It is important 'TARGET' is last here so that it overrides our less
    # informed choices for BUILD & HOST if TARGET happens to be the same as
    # either of them.
    for thing in ['BUILD', 'HOST', 'TARGET']:
        bb.debug(1, "rust_gen_target for " + thing)
        features = ""
        cpu = "generic"
        arch = d.getVar('{}_ARCH'.format(thing))
        abi = ""
        if thing is "TARGET":
            abi = d.getVar('ABIEXTENSION')
            # arm and armv7 have different targets in llvm
            if arch == "arm" and target_is_armv7(d):
                arch = 'armv7'
            features = d.getVar('TARGET_LLVM_FEATURES') or ""
            cpu = d.getVar('TARGET_LLVM_CPU')
        rust_gen_target(d, thing, wd, features, cpu, arch, abi)
}

INHIBIT_DEFAULT_RUST_DEPS = "1"

export WRAPPER_TARGET_CC = "${CCACHE}${TARGET_PREFIX}gcc --sysroot=${STAGING_DIR_TARGET} ${TARGET_CC_ARCH} ${SECURITY_NOPIE_CFLAGS}"
export WRAPPER_TARGET_CXX = "${CCACHE}${TARGET_PREFIX}g++ --sysroot=${STAGING_DIR_TARGET} ${TARGET_CC_ARCH} ${SECURITY_NOPIE_CFLAGS}"
export WRAPPER_TARGET_CCLD = "${TARGET_PREFIX}gcc --sysroot=${STAGING_DIR_TARGET} ${TARGET_CC_ARCH} ${SECURITY_NOPIE_CFLAGS}"
export WRAPPER_TARGET_LDFLAGS = "${TARGET_LDFLAGS}"
export WRAPPER_TARGET_AR = "${TARGET_PREFIX}ar"

python do_configure:prepend() {
    targets = [d.getVar("TARGET_SYS", True), "{}-unknown-linux-gnu".format(d.getVar("HOST_ARCH", True))]
    hosts = ["{}-unknown-linux-gnu".format(d.getVar("HOST_ARCH", True))]
}

INSANE_SKIP:${RUSTLIB_TARGET_PN} = "file-rdeps arch ldflags"
SKIP_FILEDEPS:${RUSTLIB_TARGET_PN} = "1"

INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"

