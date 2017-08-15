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

inherit binary-compress
FILES_COMPRESS = "/boot/init"

SRCREV = "7d1b49da3f9b7f2215c3e9f357c9b104efef2aa2"
SRCBRANCH = "17.06-resin"
SRC_URI = "\
  git://github.com/resin-os/docker.git;branch=${SRCBRANCH};nobranch=1 \
  file://docker.service \
  file://docker-host.service \
  file://var-lib-docker.mount \
  file://docker.conf.systemd \
"

# Apache-2.0 for docker
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=9740d093a080530b5c5c6573df9af45a"

S = "${WORKDIR}/git"

BBCLASSEXTEND = " native"

DOCKER_VERSION = "17.06.0-dev"
PV = "${DOCKER_VERSION}+git${SRCREV}"

DEPENDS_append_class-native = " go"
DEPENDS_append_class-target = " systemd go-cross"
RDEPENDS_${PN}_class-target = "curl util-linux iptables tini systemd"
RRECOMMENDS_${PN} += " kernel-module-nf-nat"
DOCKER_PKG="github.com/docker/docker"

inherit systemd

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
    i586|i686)
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
  export CGO_CFLAGS="${CFLAGS} ${TARGET_CC_ARCH} --sysroot=${STAGING_DIR_TARGET}"
  export CGO_LDFLAGS="${LDFLAGS}  ${TARGET_CC_ARCH} --sysroot=${STAGING_DIR_TARGET}"

  export DOCKER_GITCOMMIT="${SRCREV}"
  export DOCKER_BUILDTAGS='exclude_graphdriver_btrfs exclude_graphdirver_zfs exclude_graphdriver_devicemapper'

  ./hack/make.sh binary-rce-docker

  # Compile mobynit
  cd .gopath/src/"${DOCKER_PKG}"/cmd/mobynit
  go build -ldflags '-extldflags "-static"' .
  cd -
}

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE_${PN} = "docker.service docker-host.service var-lib-docker.mount"

do_install() {
  mkdir -p ${D}/${bindir}
  install -m 0755 ${S}/bundles/${DOCKER_VERSION}/binary-rce-docker/rce-docker ${D}/${bindir}/rce-docker
  install -d ${D}/boot
  install -m 0755 ${S}/cmd/mobynit/mobynit ${D}/boot/init

  ln -sf rce-docker ${D}/${bindir}/docker
  ln -sf rce-docker ${D}/${bindir}/dockerd
  ln -sf rce-docker ${D}/${bindir}/docker-containerd
  ln -sf rce-docker ${D}/${bindir}/docker-containerd-shim
  ln -sf rce-docker ${D}/${bindir}/docker-containerd-ctr
  ln -sf rce-docker ${D}/${bindir}/docker-runc
  ln -sf rce-docker ${D}/${bindir}/docker-proxy

  install -d ${D}${systemd_unitdir}/system
  install -m 0644 ${S}/contrib/init/systemd/docker.* ${D}/${systemd_unitdir}/system

  install -m 0644 ${WORKDIR}/docker.service ${D}/${systemd_unitdir}/system
  sed -i "s/@DOCKER_STORAGE@/${DOCKER_STORAGE}/g" ${D}${systemd_unitdir}/system/docker.service

  install -m 0644 ${WORKDIR}/docker-host.service ${D}/${systemd_unitdir}/system
  sed -i "s/@DOCKER_STORAGE@/${DOCKER_STORAGE}/g" ${D}${systemd_unitdir}/system/docker-host.service

  install -m 0644 ${WORKDIR}/var-lib-docker.mount ${D}/${systemd_unitdir}/system

  if ${@bb.utils.contains('DISTRO_FEATURES','development-image','true','false',d)}; then
    install -d ${D}${sysconfdir}/systemd/system/docker.service.d
    install -c -m 0644 ${WORKDIR}/docker.conf.systemd ${D}${sysconfdir}/systemd/system/docker.service.d/docker.conf
    sed -i "s/@DOCKER_STORAGE@/${DOCKER_STORAGE}/g" ${D}${sysconfdir}/systemd/system/docker.service.d/docker.conf
  fi

  install -d ${D}/home/root/.docker
}

inherit useradd
USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} = "-r docker"

FILES_${PN} += " \
  /lib/systemd/system/* \
  /home/root/.docker/ \
  /boot/init \
  "
