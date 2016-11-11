inherit cross

require go_${PV}.inc

DEPENDS_append = " virtual/${TARGET_PREFIX}gcc libgcc"
INHIBIT_SYSROOT_STRIP = "1"
#
# FIXME
# Ugly fix to ONLY change GOROOT_BOOTSTRAP
# Fix pushed to upstream: https://github.com/mem/oe-meta-go/pull/4
# https://github.com/mem/oe-meta-go/pull/4/commits/8e2353e99df3f82c9b2449b906a616cfa19656cf
#
do_compile() {
  export GOROOT_BOOTSTRAP="${STAGING_DIR_NATIVE}${libdir_native}/go-bootstrap-${GO_BOOTSTRAP_VERSION}"

  ## Setting `$GOBIN` doesn't do any good, looks like it ends up copying binaries there.
  export GOROOT_FINAL="${SYSROOT}${libdir}/go"

  setup_go_arch

  setup_cgo_gcc_wrapper

  ## TODO: consider setting GO_EXTLINK_ENABLED
  export CGO_ENABLED="${GO_CROSS_CGO_ENABLED}"
  export CC=${BUILD_CC}
  export CC_FOR_TARGET="${WORKDIR}/${TARGET_PREFIX}gcc"
  export CXX_FOR_TARGET="${WORKDIR}/${TARGET_PREFIX}g++"
  export GO_GCFLAGS="${HOST_CFLAGS}"
  export GO_LDFLAGS="${HOST_LDFLAGS}"

  set > ${WORKDIR}/go-${PV}.env
  cd ${WORKDIR}/go-${PV}/go/src && bash -x ./make.bash

  # log the resulting environment
  env "GOROOT=${WORKDIR}/go-${PV}/go" "${WORKDIR}/go-${PV}/go/bin/go" env
}

# Use GOARCH 386 for i686 too
# Fix pushed to upstream: https://github.com/mem/oe-meta-go/pull/4
# https://github.com/mem/oe-meta-go/pull/4/commits/2585beb9660e72a3502b92d56a469b4c1d620e24
#
setup_go_arch_append() {
  case "${TARGET_ARCH}" in
    i*86)
      GOARCH=386
      ;;
  esac
  export GOARCH
}
