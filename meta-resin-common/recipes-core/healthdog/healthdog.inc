# Link dynamically
RUSTFLAGS += "-C prefer-dynamic"

RDEPENDS_${PN} += "libstd-rs"

DEPENDS += "patchelf-native"

# Add function from rust-bin.bbclass to fix up binary RUNPATH. Without
# this we will fail at runtime unable to find libstd.so.
do_rust_bin_fixups() {
    for f in `find ${PKGD} -name '*.so*'`; do
        echo "Strip rust note: $f"
        ${OBJCOPY} -R .note.rustc $f $f
    done

    for f in `find ${PKGD}`; do
        file "$f" | grep -q ELF || continue
        readelf -d "$f" | grep RUNPATH | grep -q rustlib || continue
        echo "Set rpath:" "$f"
        patchelf --set-rpath '$ORIGIN:'${rustlibdir}:${rustlib} "$f"
    done
}
PACKAGE_PREPROCESS_FUNCS += "do_rust_bin_fixups"
