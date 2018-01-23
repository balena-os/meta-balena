# This work is based on the commit
# https://github.com/meta-rust/meta-rust/commit/463622c0c6828e7fb970f46f9bf0dcf156345373
# It ports rpath fix to this package because it uses cargo and not rust-bin
# bbclass.
# This fix replaces the post patching of the binary' rpath with correct
# compiler arguments.
# TODO: For now this is needed only for this package. In the future, we should
# probably turn this into a bbclass for rust libraries and binaries to be able
# to reuse this fix.

# From rust.bbclass
rustlib_suffix="${TUNE_ARCH}${TARGET_VENDOR}-${TARGET_OS}/rustlib/${HOST_SYS}/lib"
rustlib="${libdir}/${rustlib_suffix}"

rustbindest ?= "${bindir}"
rustlibdest ?= "${rustlibdir}"
RUST_RPATH_ABS ?= "${rustlibdir}:${rustlib}"

def relative_rpaths(paths, base):
    relpaths = set()
    for p in paths.split(':'):
        if p == base:
            relpaths.add('\$ORIGIN')
            continue
        relpaths.add(os.path.join('\$ORIGIN', os.path.relpath(p, base)))
    return '-rpath=' + ':'.join(relpaths) if len(relpaths) else ''

RUST_LIB_RPATH_FLAGS ?= "${@relative_rpaths(d.getVar('RUST_RPATH_ABS', True), d.getVar('rustlibdest', True))}"
RUST_BIN_RPATH_FLAGS ?= "${@relative_rpaths(d.getVar('RUST_RPATH_ABS', True), d.getVar('rustbindest', True))}"

def libfilename(d):
    if d.getVar('CRATE_TYPE', True) == 'dylib':
        return d.getVar('LIBNAME', True) + '.so'
    else:
        return d.getVar('LIBNAME', True) + '.rlib'

def link_args(d, bin):
    linkargs = []
    if bin:
        rpaths = d.getVar('RUST_BIN_RPATH_FLAGS', False)
    else:
        rpaths = d.getVar('RUST_LIB_RPATH_FLAGS', False)
        if d.getVar('CRATE_TYPE', True) == 'dylib':
            linkargs.append('-soname')
            linkargs.append(libfilename(d))
    if len(rpaths):
        linkargs.append(rpaths)
    if len(linkargs):
        return ' '.join(['-Wl,' + arg for arg in linkargs])
    else:
        return ''

# Link dynamically
RUSTFLAGS += "-C prefer-dynamic -C link-args=${@link_args(d, True)}"
RDEPENDS_${PN} += "libstd-rs"

do_rust_bin_fixups() {
    for f in `find ${PKGD} -name '*.so*'`; do
        echo "Strip rust note: $f"
        ${OBJCOPY} -R .note.rustc $f $f
    done
}
PACKAGE_PREPROCESS_FUNCS += "do_rust_bin_fixups"
