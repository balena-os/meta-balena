SUMMARY = "Rust compiler and runtime libaries"
HOMEPAGE = "http://www.rust-lang.org"
SECTION = "devel"
LICENSE = "MIT | Apache-2.0"

inherit rust
inherit cargo_common

DEPENDS += "file-native python-native"

# We generate local targets, and need to be able to locate them
export RUST_TARGET_PATH="${WORKDIR}/targets/"

export FORCE_CRATE_HASH="${BB_TASKHASH}"

setup_cargo_environment () {
    # The first step is to build bootstrap and some early stage tools,
    # these are build for the same target as the snapshot, e.g.
    # x86_64-unknown-linux-gnu.
    # Later stages are build for the native target (i.e. target.x86_64-linux)
    cargo_common_do_configure

    echo "[target.${RUST_BUILD_SYS}]" >> ${CARGO_HOME}/config
    echo "linker = '${RUST_TARGET_CCLD}'" >> ${CARGO_HOME}/config
}

# Right now this is focused on arm-specific tune features.
# We get away with this for now as one can only use x86-64 as the build host
# (not arm).
# Note that TUNE_FEATURES is _always_ refering to the target, so we really
# don't want to use this for the host/build.
def llvm_features_from_tune(d):
    f = []
    feat = d.getVar('TUNE_FEATURES')
    if not feat:
        return ""
    feat = frozenset(feat.split())

    if 'vfpv4' in feat:
        f.append("+vfp4")
    if 'vfpv3' in feat:
        f.append("+vfp3")
    if 'vfpv3d16' in feat:
        f.append("+d16")

    if 'vfpv2' in feat or 'vfp' in feat:
        f.append("+vfp2")

    if 'neon' in feat:
        f.append("+neon")

    if 'aarch64' in feat:
        f.append("+v8")

    v7=frozenset(['armv7a', 'armv7r', 'armv7m', 'armv7ve'])
    if not feat.isdisjoint(v7):
        f.append("+v7")
    if 'armv6' in feat:
        f.append("+v6")

    if 'dsp' in feat:
        f.append("+dsp")

    if d.getVar('ARM_THUMB_OPT') is "thumb":
        if not feat.isdisjoint(v7):
            f.append("+thumb2")
        f.append("+thumb-mode")

    if 'cortexa5' in feat:
        f.append("+a5")
    if 'cortexa7' in feat:
        f.append("+a7")
    if 'cortexa9' in feat:
        f.append("+a9")
    if 'cortexa15' in feat:
        f.append("+a15")
    if 'cortexa17' in feat:
        f.append("+a17")

    # Seems like it could be infered by the lack of vfp options, but we'll
    # include it anyhow
    if 'soft' in feat:
        f.append("+soft-float")

    return ','.join(f)

# TARGET_CC_ARCH changes from build/cross/target so it'll do the right thing
# this should go away when https://github.com/rust-lang/rust/pull/31709 is
# stable (1.9.0?)
def llvm_features_from_cc_arch(d):
    f = []
    feat = d.getVar('TARGET_CC_ARCH')
    if not feat:
        return ""
    feat = frozenset(feat.split())

    if '-mmmx' in feat:
        f.append("+mmx")
    if '-msse' in feat:
        f.append("+sse")
    if '-msse2' in feat:
        f.append("+sse2")
    if '-msse3' in feat:
        f.append("+sse3")
    if '-mssse3' in feat:
        f.append("+ssse3")
    if '-msse4.1' in feat:
        f.append("+sse4.1")
    if '-msse4.2' in feat:
        f.append("+sse4.2")
    if '-msse4a' in feat:
        f.append("+sse4a")
    if '-mavx' in feat:
        f.append("+avx")
    if '-mavx2' in feat:
        f.append("+avx2")

    return ','.join(f)

## arm-unknown-linux-gnueabihf
DATA_LAYOUT[arm] = "e-m:e-p:32:32-i64:64-v128:64:128-a:0:32-n32-S64"
LLVM_TARGET[arm] = "${RUST_TARGET_SYS}"
TARGET_ENDIAN[arm] = "little"
TARGET_POINTER_WIDTH[arm] = "32"
MAX_ATOMIC_WIDTH[arm] = "64"
FEATURES[arm] = "+v6,+vfp2"

## aarch64-unknown-linux-gnu
DATA_LAYOUT[aarch64] = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
LLVM_TARGET[aarch64] = "aarch64-unknown-linux-gnu"
TARGET_ENDIAN[aarch64] = "little"
TARGET_POINTER_WIDTH[aarch64] = "64"
MAX_ATOMIC_WIDTH[aarch64] = "128"

## x86_64-unknown-linux-gnu
DATA_LAYOUT[x86_64] = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
LLVM_TARGET[x86_64] = "x86_64-unknown-linux-gnu"
TARGET_ENDIAN[x86_64] = "little"
TARGET_POINTER_WIDTH[x86_64] = "64"
MAX_ATOMIC_WIDTH[x86_64] = "64"

## i686-unknown-linux-gnu
DATA_LAYOUT[i686] = "e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128"
LLVM_TARGET[i686] = "i686-unknown-linux-gnu"
TARGET_ENDIAN[i686] = "little"
TARGET_POINTER_WIDTH[i686] = "32"
MAX_ATOMIC_WIDTH[i686] = "64"

## XXX: a bit of a hack so qemux86 builds, clone of i686-unknown-linux-gnu above
DATA_LAYOUT[i586] = "e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128"
LLVM_TARGET[i586] = "i586-unknown-linux-gnu"
TARGET_ENDIAN[i586] = "little"
TARGET_POINTER_WIDTH[i586] = "32"
MAX_ATOMIC_WIDTH[i586] = "64"

def arch_for(d, thing):
    return d.getVar('{}_ARCH'.format(thing))

def sys_for(d, thing):
    return d.getVar('{}_SYS'.format(thing))

def prefix_for(d, thing):
    return d.getVar('{}_PREFIX'.format(thing))

# Convert a normal arch (HOST_ARCH, TARGET_ARCH, BUILD_ARCH, etc) to something
# rust's internals won't choke on.
def arch_to_rust_target_arch(arch):
    if arch == "i586" or arch == "i686":
        return "x86"
    else:
        return arch

# generates our target CPU value
def llvm_cpu(d):
    cpu = d.getVar('PACKAGE_ARCH')
    target = d.getVar('TRANSLATED_TARGET_ARCH')

    trans = {}
    trans['corei7-64'] = "corei7"
    trans['core2-32'] = "core2"
    trans['x86-64'] = "x86-64"
    trans['i686'] = "i686"
    trans['i586'] = "i586"

    try:
        return trans[cpu]
    except:
        return trans.get(target, "generic")

TARGET_LLVM_CPU="${@llvm_cpu(d)}"
TARGET_LLVM_FEATURES = "${@llvm_features_from_tune(d)} ${@llvm_features_from_cc_arch(d)}"

# class-native implies TARGET=HOST, and TUNE_FEATURES only describes the real
# (original) target.
TARGET_LLVM_FEATURES_class-native = "${@llvm_features_from_cc_arch(d)}"

def rust_gen_target(d, thing, wd):
    import json
    from distutils.version import LooseVersion
    arch = arch_for(d, thing)
    sys = sys_for(d, thing)
    prefix = prefix_for(d, thing)

    features = ""
    cpu = "generic"
    if thing is "TARGET":
        features = d.getVar('TARGET_LLVM_FEATURES') or ""
        cpu = d.getVar('TARGET_LLVM_CPU')
    features = features or d.getVarFlag('FEATURES', arch) or ""
    features = features.strip()

    # build tspec
    tspec = {}
    tspec['llvm-target'] = d.getVarFlag('LLVM_TARGET', arch)
    tspec['data-layout'] = d.getVarFlag('DATA_LAYOUT', arch)
    tspec['max-atomic-width'] = d.getVarFlag('MAX_ATOMIC_WIDTH', arch)
    tspec['target-pointer-width'] = d.getVarFlag('TARGET_POINTER_WIDTH', arch)
    tspec['target-endian'] = d.getVarFlag('TARGET_ENDIAN', arch)
    tspec['arch'] = arch_to_rust_target_arch(arch)
    tspec['os'] = "linux"
    tspec['env'] = "gnu"
    tspec['vendor'] = "unknown"
    tspec['target-family'] = "unix"
    tspec['linker'] = "{}{}gcc".format(d.getVar('CCACHE'), prefix)
    tspec['ar'] = "{}ar".format(prefix)
    tspec['cpu'] = cpu
    if features is not "":
        tspec['features'] = features
    tspec['dynamic-linking'] = True
    tspec['executables'] = True
    tspec['linker-is-gnu'] = True
    tspec['linker-flavor'] = "gcc"
    tspec['has-rpath'] = True
    tspec['has-elf-tls'] = True
    tspec['position-independent-executables'] = True

    # Don't use jemalloc as it doesn't work for many targets.
    # https://github.com/rust-lang/rust/pull/37392
    # From 1.20.0 and forward, system allocator is the default.
    if LooseVersion(d.getVar("PV")) < LooseVersion("1.20.0"):
        tspec['exe-allocation-crate'] = "alloc_system"
        tspec['lib-allocation-crate'] = "alloc_system"

    # write out the target spec json file
    with open(wd + sys + '.json', 'w') as f:
        json.dump(tspec, f, indent=4)


python do_rust_gen_targets () {
    wd = d.getVar('WORKDIR') + '/targets/'
    # It is important 'TARGET' is last here so that it overrides our less
    # informed choices for BUILD & HOST if TARGET happens to be the same as
    # either of them.
    for thing in ['BUILD', 'HOST', 'TARGET']:
        bb.debug(1, "rust_gen_target for " + thing)
        rust_gen_target(d, thing, wd)
}
addtask rust_gen_targets after do_patch before do_compile
do_rust_gen_targets[dirs] += "${WORKDIR}/targets"


do_rust_setup_snapshot () {
    for installer in "${WORKDIR}/rust-snapshot-components/"*"/install.sh"; do
        "${installer}" --prefix="${WORKDIR}/rust-snapshot" --disable-ldconfig
    done

    # Some versions of rust (e.g. 1.18.0) tries to find cargo in stage0/bin/cargo
    # and fail without it there.
    mkdir -p ${RUSTSRC}/build/${BUILD_SYS}
    ln -s ${WORKDIR}/rust-snapshot/ ${RUSTSRC}/build/${BUILD_SYS}/stage0
}
addtask rust_setup_snapshot after do_unpack before do_configure
do_rust_setup_snapshot[dirs] += "${WORKDIR}/rust-snapshot"


python do_configure() {
    import json
    try:
        import configparser
    except ImportError:
        import ConfigParser as configparser

    # toml is rather similar to standard ini like format except it likes values
    # that look more JSON like. So for our purposes simply escaping all values
    # as JSON seem to work fine.

    e = lambda s: json.dumps(s)

    config = configparser.RawConfigParser()

    # [target.ARCH-poky-linux]
    target_section = "target.{}".format(d.getVar('TARGET_SYS', True))
    config.add_section(target_section)

    llvm_config = d.expand("${STAGING_DIR_NATIVE}${bindir_native}/llvm-config")
    config.set(target_section, "llvm-config", e(llvm_config))

    config.set(target_section, "cxx", e(d.expand("${RUST_TARGET_CXX}")))
    config.set(target_section, "cc", e(d.expand("${RUST_TARGET_CC}")))

    # [rust]
    config.add_section("rust")
    config.set("rust", "rpath", e(True))
    config.set("rust", "channel", e("stable"))

    # Don't use jemalloc as it doesn't work for many targets.
    # https://github.com/rust-lang/rust/pull/37392
    config.set("rust", "use-jemalloc", e(False))

    # Whether or not to optimize the compiler and standard library
    config.set("rust", "optimize", e(True))

    # [build]
    config.add_section("build")
    config.set("build", "submodules", e(False))
    config.set("build", "docs", e(False))

    rustc = d.expand("${WORKDIR}/rust-snapshot/bin/rustc")
    config.set("build", "rustc", e(rustc))

    cargo = d.expand("${WORKDIR}/rust-snapshot/bin/cargo")
    config.set("build", "cargo", e(cargo))

    targets = [d.getVar("TARGET_SYS", True)]
    config.set("build", "target", e(targets))

    hosts = [d.getVar("HOST_SYS", True)]
    config.set("build", "host", e(targets))

    config.set("build", "build", e(d.getVar("BUILD_SYS", True)))

    with open("config.toml", "w") as f:
        config.write(f)

    # set up ${WORKDIR}/cargo_home
    bb.build.exec_func("setup_cargo_environment", d)
}


rust_runx () {
    echo "COMPILE ${PN}" "$@"

    # CFLAGS, LDFLAGS, CXXFLAGS, CPPFLAGS are used by rust's build for a
    # wide range of targets (not just TARGET). Yocto's settings for them will
    # be inappropriate, avoid using.
    unset CFLAGS
    unset LDFLAGS
    unset CXXFLAGS
    unset CPPFLAGS

    oe_cargo_fix_env

    python src/bootstrap/bootstrap.py "$@" --verbose
}


do_compile () {
    rust_runx build
}


rust_do_dist_install () {
    rust_runx dist

    for installer in "build/tmp/dist/rustc"*"/install.sh"; do
        "${installer}" --destdir="${D}" --prefix="${prefix}" --disable-ldconfig
    done

    for installer in "build/tmp/dist/rust-std"*"/install.sh"; do
        "${installer}" --destdir="${D}" --prefix="${prefix}" --disable-ldconfig
    done

    # Install our custom target.json files
    local td="${D}${libdir}/rustlib/"
    install -d "$td"
    for tgt in "${WORKDIR}/targets/"* ; do
        install -m 0644 "$tgt" "$td"
    done

    # cleanup after rust-installer since we don't need these bits
    rm ${D}/${libdir}/rustlib/install.log
    rm ${D}/${libdir}/rustlib/rust-installer-version
    rm ${D}/${libdir}/rustlib/uninstall.sh
    rm ${D}/${libdir}/rustlib/components
}


do_install () {
    rust_do_dist_install
}
# ex: sts=4 et sw=4 ts=8
