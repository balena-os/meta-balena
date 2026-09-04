# A second, pinned Go toolchain used only by the runsc recipe.
#
# gVisor's "go" branch requires go >= 1.26.3, while GOVERSION for this layer is
# 1.24.6 because that is what balena-engine v25 needs. Rather than move the
# whole layer, runsc builds with this toolchain and nothing else does.
#
# Deliberately does not PROVIDE go-native: it must not compete with
# go-binary-native, which remains the layer's bootstrap compiler.
#
# Only a native compiler is needed, with no matching go-cross or go-runtime,
# because runsc is built with CGO_ENABLED=0. A pure-Go build cross-compiles
# from GOOS and GOARCH alone.

SUMMARY = "Go programming language compiler, pinned for runsc"
HOMEPAGE = "http://golang.org/"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=7998cb338f82d15c0eff93b7004d272a"

# Checksums available at https://go.dev/dl/
SRC_URI = "https://dl.google.com/go/go${PV}.${BUILD_GOOS}-${BUILD_GOARCH}.tar.gz;name=go_${BUILD_GOTUPLE}"
SRC_URI[go_linux_amd64.sha256sum] = "d0f743b33e8d8945e6b1f432edd15785c70507121d6e2a723b21285eddf8b57b"
SRC_URI[go_linux_arm64.sha256sum] = "211ffced9dcb9633a55eac6364816ec0ddd951389a740e88fa8b3337971bdda0"
SRC_URI[go_linux_ppc64le.sha256sum] = "0ddf3ecab842013e6bd618602823a0b8158a18d3e9362f2540463ea5aa184975"

UPSTREAM_CHECK_URI = "https://golang.org/dl/"
UPSTREAM_CHECK_REGEX = "go(?P<pver>1\.26(\.\d+)*)\.linux"

CVE_PRODUCT = "golang:go"

S = "${UNPACKDIR}/go"

inherit goarch native

# The tarball is a prebuilt toolchain.
do_compile() {
    :
}

do_install() {
    find ${S} -depth -type d -name testdata -exec rm -rf {} +

    install -d ${D}${bindir} ${D}${libdir}/go-runsc
    cp --preserve=mode,timestamps -R ${S}/. ${D}${libdir}/go-runsc/

    # GOROOT is resolved relative to the wrapper, the same way
    # go-binary-native does it, so the native sysroot stays relocatable.
    rm -f ${D}${bindir}/go-runsc
    cat <<END >${D}${bindir}/go-runsc
#!/bin/bash
here=\`dirname \$0\`
export GOROOT="\${GOROOT:-\`readlink -f \$here/../lib/go-runsc\`}"
exec \$GOROOT/bin/go "\$@"
END
    chmod +x ${D}${bindir}/go-runsc
}
