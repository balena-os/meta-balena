HOMEPAGE = "https://gvisor.dev/"
SUMMARY = "gVisor OCI runtime"
DESCRIPTION = "runsc is the OCI runtime of gVisor, an application kernel that \
implements a substantial portion of the Linux system call interface in \
userspace. It runs a container against that kernel instead of the host one."
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=e566fe37b81dd469e93876dc021ca01c"

# goarch only, for TARGET_GOARCH. go.bbclass is deliberately not inherited: it
# builds in GOPATH mode and overrides do_unpack to rewrite the checkout path,
# neither of which suits a plain module build.
inherit goarch

# go-runsc-native pins go 1.26.8 for this recipe alone. GOVERSION for the layer
# is 1.24.6, which is below what gVisor's go.mod requires.
DEPENDS = "go-runsc-native"

GO_IMPORT = "gvisor.dev/gvisor"

# The "go" branch is upstream's generated Go-only tree. Since 2026-07-29 it also
# carries the artifacts the Bazel build used to generate -- the *_go_proto
# packages and the go:embed blobs vdso_*.so and sighandler.built-in.*.bin --
# which is what makes a plain `go build` possible. Earlier commits omit them and
# cannot be built without Bazel, so do not move SRCREV backwards.
SRC_URI = "git://github.com/google/gvisor;branch=go;protocol=https;destsuffix=git"

SRCREV = "f0f1b2ea279ae3c96fe97d7317ae28c826bbdcd8"
PV = "20260902+git${SRCPV}"

S = "${UNPACKDIR}/git"

# Out-of-tree build dir. ${S}/runsc is the Go package directory, and
# go build -o pointed at an existing directory writes the binary inside it.
B = "${WORKDIR}/build"

# The sentry is implemented with raw syscalls and upstream supports these two
# architectures only, so there is nothing to build for arm32.
COMPATIBLE_HOST = "(x86_64|aarch64).*-linux"

GOPROXY ??= "https://proxy.golang.org,direct"

# The runtime drop-in lives under /usr/lib rather than /etc because the hostapp
# extension carrying this binary strips /etc from its rootfs.
BALENA_RUNTIMES_DIR = "/usr/lib/balena/runtimes.d"

do_configure[noexec] = "1"

do_compile[network] = "1"
do_compile() {
    cd ${S}

    # The wrapper sets GOROOT relative to itself. Clear both so no inherited
    # value can redirect the build at the layer's default toolchain.
    unset GOROOT GOPATH

    export GOCACHE="${WORKDIR}/go-cache"
    export GOPROXY="${GOPROXY}"
    export GOOS="linux"
    export GOARCH="${TARGET_GOARCH}"

    # Fail loudly rather than download a toolchain. go-runsc-native already
    # satisfies the go.mod directive, so a fetch here would mean the pin drifted.
    export GOTOOLCHAIN="local"

    # runsc re-execs itself to drop capabilities when built with cgo, which
    # upstream calls out as slower. A pure-Go build also cross-compiles from
    # GOOS and GOARCH alone, so no go-cross is needed.
    export CGO_ENABLED="0"

    # -trimpath keeps the build directory out of the binary, which the
    # buildpaths QA check rejects.
    export GOFLAGS="-trimpath"

    # -s and -w drop the symbol table and DWARF, which is most of the binary.
    # The extension ships to the data partition, so size is worth more here than
    # symbolised panic traces. version.version is otherwise the literal
    # "VERSION_MISSING", and -X still applies with -s.
    go-runsc build -ldflags "-s -w -X ${GO_IMPORT}/runsc/version.version=${PV}" \
        -o ${B}/runsc ${GO_IMPORT}/runsc
}

do_install() {
    install -d ${D}${bindir}
    # gVisor requires the binary to be readable and executable by all users.
    install -m 0755 ${B}/runsc ${D}${bindir}/runsc

    install -d ${D}${BALENA_RUNTIMES_DIR}
    cat >${D}${BALENA_RUNTIMES_DIR}/runsc.conf <<EOF
# Registers runsc with balenaEngine. balena-runtimes-gen turns every drop-in in
# this directory into an --add-runtime flag for balenad.
runsc=${bindir}/runsc
EOF
    chmod 0644 ${D}${BALENA_RUNTIMES_DIR}/runsc.conf
}

FILES:${PN} += " ${BALENA_RUNTIMES_DIR}/runsc.conf "

# Go produces its own stripped binaries and the standard strip corrupts them.
INHIBIT_PACKAGE_STRIP = "1"
INSANE_SKIP:${PN} += "already-stripped"
