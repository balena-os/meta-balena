HOMEPAGE = "http://www.docker.com"
SUMMARY = "Linux container runtime"
DESCRIPTION = "Linux container runtime \
 Docker complements kernel namespacing with a high-level API which \
 operates at the process level. It runs unix processes with strong \
 guarantees of isolation and repeatability across servers. \
 . \
 Docker is a great building block for automating distributed systems: \
 large-scale web deployments, database clusters, continuous deployment \
 systems, private PaaS, service-oriented architectures, etc. \
 . \
 This package contains the daemon and client. Using docker.io on non-amd64 \
 hosts is not supported at this time. Please be careful when using it \
 on anything besides amd64. \
 . \
 Also, note that kernel version 3.8 or above is required for proper \
 operation of the daemon process, and that any lower versions may have \
 subtle and/or glaring issues. \
 "

SRCREV = "20f81dde9bd97c86b2d0e33bbbf1388018611929"
SRCBRANCH = "v1.10.3"
SRC_URI = "\
  git://github.com/docker/docker.git;branch=${SRCBRANCH};nobranch=1 \
  file://docker.service \
  file://var-lib-docker.mount \
	"

# Apache-2.0 for docker
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=aadc30f9c14d876ded7bedc0afd2d3d7"

S = "${WORKDIR}/git"

DOCKER_VERSION = "1.10.3"
PV = "${DOCKER_VERSION}+git${SRCREV}"

DEPENDS = " \
  go-cross \
  btrfs-tools \
  "

DEPENDS_append_class-target = "lvm2"
RDEPENDS_${PN} = "curl git util-linux iptables"
RRECOMMENDS_${PN} += " kernel-module-dm-thin-pool kernel-module-nf-nat"
DOCKER_PKG="github.com/docker/docker"

do_configure() {
}

do_compile() {
  export PATH=${STAGING_BINDIR_NATIVE}/${HOST_SYS}:$PATH

  export GOHOSTOS="linux"
  export GOOS="linux"

  case "${TARGET_ARCH}" in
    x86_64)
      GOARCH=amd64
      ;;
    i586)
      GOARCH=386
      ;;
    arm)
      GOARCH=${TARGET_ARCH}
      case "${TUNE_PKGARCH}" in
        cortexa*)
          export GOARM=7
          ;;
      esac
      ;;
    aarch64)
      # ARM64 is invalid for Go 1.4
      GOARCH=arm64
      ;;
    *)
      GOARCH="${TARGET_ARCH}"
      ;;
  esac
  export GOARCH

  # Set GOPATH. See 'PACKAGERS.md'. Don't rely on
  # docker to download its dependencies but rather
  # use dependencies packaged independently.
  cd ${S}
  rm -rf .gopath
  mkdir -p .gopath/src/"$(dirname "${DOCKER_PKG}")"
  ln -sf ../../../.. .gopath/src/"${DOCKER_PKG}"
  export GOPATH="${S}/.gopath:${S}/vendor:${STAGING_DIR_TARGET}/${prefix}/local/go"
  cd -

  export CGO_ENABLED="1"

  # Pass the needed cflags/ldflags so that cgo
  # can find the needed headers files and libraries
  export CGO_CFLAGS="${BUILDSDK_CFLAGS} ${TARGET_CC_ARCH}"
  export CGO_LDFLAGS="${BUILDSDK_LDFLAGS}  ${TARGET_CC_ARCH} --sysroot=${STAGING_DIR_TARGET}"

  DOCKER_GITCOMMIT="${SRCREV}" \
    ./hack/make.sh dynbinary
}

inherit systemd

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE_${PN} = "docker.service var-lib-docker.mount"

do_install() {
  mkdir -p ${D}/${bindir}
  cp ${S}/bundles/${DOCKER_VERSION}/dynbinary/docker-${DOCKER_VERSION} \
    ${D}/${bindir}/docker

  install -d ${D}${systemd_unitdir}/system
  install -m 644 ${S}/contrib/init/systemd/docker.* ${D}/${systemd_unitdir}/system
  install -m 644 ${WORKDIR}/docker.service ${D}/${systemd_unitdir}/system
  install -m 644 ${WORKDIR}/var-lib-docker.mount ${D}/${systemd_unitdir}/system
}

inherit useradd
USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} = "-r docker"

FILES_${PN} += "/lib/systemd/system/*"
