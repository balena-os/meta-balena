##
## Purpose:
## This class is used by any recipes that are built using
## Cargo.

inherit cargo_common

# the binary we will use
CARGO = "cargo"

# We need cargo to compile for the target
BASEDEPENDS_append = " cargo-native"

# Ensure we get the right rust variant
DEPENDS_append_class-target = " virtual/${TARGET_PREFIX}rust ${RUSTLIB_DEP}"
DEPENDS_append_class-native = " rust-native"

# Cargo only supports in-tree builds at the moment
B = "${S}"

# In case something fails in the build process, give a bit more feedback on
# where the issue occured
export RUST_BACKTRACE = "1"

RUSTFLAGS ??= ""
CARGO_BUILD_FLAGS = "-v --target ${HOST_SYS} --release"
RUST_TARGET_PATH = "${STAGING_LIBDIR_NATIVE}/rustlib"

# This is based on the content of CARGO_BUILD_FLAGS and generally will need to
# change if CARGO_BUILD_FLAGS changes.
CARGO_TARGET_SUBDIR="${HOST_SYS}/release"
oe_cargo_build () {
	export RUSTFLAGS="${RUSTFLAGS}"
	export RUST_TARGET_PATH="${RUST_TARGET_PATH}"
	bbnote "cargo = $(which ${CARGO})"
	bbnote "rustc = $(which ${RUSTC})"
	bbnote "${CARGO} build ${CARGO_BUILD_FLAGS} $@"
	"${CARGO}" build ${CARGO_BUILD_FLAGS} "$@"
}

cargo_do_compile () {
	oe_cargo_fix_env
	oe_cargo_build
}

cargo_do_install () {
	local have_installed=false
	for tgt in "${B}/target/${CARGO_TARGET_SUBDIR}/"*; do
		if [[ $tgt == *.so || $tgt == *.rlib ]]; then
			install -d "${D}${rustlibdir}"
			install -m755 "$tgt" "${D}${rustlibdir}"
			have_installed=true
		elif [ -f "$tgt" ] && [ -x "$tgt" ]; then
			install -d "${D}${bindir}"
			install -m755 "$tgt" "${D}${bindir}"
			have_installed=true
		fi
	done
	if ! $have_installed; then
		die "Did not find anything to install"
	fi
}

EXPORT_FUNCTIONS do_compile do_install
