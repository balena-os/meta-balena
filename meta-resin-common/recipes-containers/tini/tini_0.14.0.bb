HOMEPAGE = "http://github.com/krallin/tini"
SUMMARY = "Minimal init for containers"
DESCRIPTION = "Tini is the simplest init you could think of. \
  All Tini does is spawn a single child (Tini is meant to be run in a container), \
  and wait for it to exit all the while reaping zombies and performing signal forwarding. \
  "

SRCREV = "949e6facb77383876aeff8a6944dde66b3089574"
SRC_URI = " \ 
  git://github.com/krallin/tini.git \
  file://0001-Do-not-strip-the-output-binary-allow-yocto-to-do-thi.patch \
  "

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=ffc9091894702bc5dcf4cc0085561ef5"

S = "${WORKDIR}/git"

inherit cmake

do_install() {
  mkdir -p ${D}/${bindir}
  install -m 0755 ${B}/tini-static ${D}/${bindir}/docker-init
}
