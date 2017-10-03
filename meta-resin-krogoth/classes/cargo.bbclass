# add crate fetch support
inherit crate-fetch
inherit rust-common

# the binary we will use
CARGO = "cargo"

# Where we download our registry and dependencies to
export CARGO_HOME = "${WORKDIR}/cargo_home"

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

# The pkg-config-rs library used by cargo build scripts disables itself when
# cross compiling unless this is defined. We set up pkg-config appropriately
# for cross compilation, so tell it we know better than it.
export PKG_CONFIG_ALLOW_CROSS = "1"

cargo_do_configure () {
	mkdir -p ${CARGO_HOME}
	echo "paths = [" > ${CARGO_HOME}/config

	for p in ${EXTRA_OECARGO_PATHS}; do
		printf "\"%s\"\n" "$p"
	done | sed -e 's/$/,/' >> ${CARGO_HOME}/config
	echo "]" >> ${CARGO_HOME}/config

	# Point cargo at our local mirror of the registry
	cat <<- EOF >> ${CARGO_HOME}/config
	[source.bitbake]
	directory = "${CARGO_HOME}/bitbake"

	[source.crates-io]
	replace-with = "bitbake"
	local-registry = "/nonexistant"
	EOF

	echo "[target.${HOST_SYS}]" >> ${CARGO_HOME}/config
	echo "linker = '${RUST_TARGET_CCLD}'" >> ${CARGO_HOME}/config
	if [ "${HOST_SYS}" != "${BUILD_SYS}" ]; then
		echo "[target.${BUILD_SYS}]" >> ${CARGO_HOME}/config
		echo "linker = '${RUST_BUILD_CCLD}'" >> ${CARGO_HOME}/config
	fi
}

RUSTFLAGS ??= ""
CARGO_BUILD_FLAGS = "-v --target ${HOST_SYS} --release"

# This is based on the content of CARGO_BUILD_FLAGS and generally will need to
# change if CARGO_BUILD_FLAGS changes.
CARGO_TARGET_SUBDIR="${HOST_SYS}/release"
oe_cargo_build () {
	export RUSTFLAGS="${RUSTFLAGS}"
	bbnote "cargo = $(which cargo)"
	bbnote "rustc = $(which rustc)"
	bbnote "${CARGO} build ${CARGO_BUILD_FLAGS} $@"
	"${CARGO}" build ${CARGO_BUILD_FLAGS} "$@"
}

oe_cargo_fix_env () {
	export CC="${RUST_TARGET_CC}"
	export CFLAGS="${CFLAGS}"
	export AR="${AR}"
	export TARGET_CC="${RUST_TARGET_CC}"
	export TARGET_CFLAGS="${CFLAGS}"
	export TARGET_AR="${AR}"
	export HOST_CC="${RUST_BUILD_CC}"
	export HOST_CFLAGS="${BUILD_CFLAGS}"
	export HOST_AR="${BUILD_AR}"
}

EXTRA_OECARGO_PATHS ??= ""

cargo_do_compile () {
	oe_cargo_fix_env
	oe_cargo_build
}

cargo_do_install () {
	local have_installed=false
	for tgt in "${B}/target/${CARGO_TARGET_SUBDIR}/"*; do
		case $tgt in
		*.so|*.rlib)
			install -d "${D}${rustlibdir}"
			install -m755 "$tgt" "${D}${rustlibdir}"
			have_installed=true
			;;
		*)
			if [ -f "$tgt" ] && [ -x "$tgt" ]; then
				install -d "${D}${bindir}"
				install -m755 "$tgt" "${D}${bindir}"
				have_installed=true
			fi
			;;
		esac
	done
	if ! $have_installed; then
		die "Did not find anything to install"
	fi
}

EXPORT_FUNCTIONS do_configure do_compile do_install
