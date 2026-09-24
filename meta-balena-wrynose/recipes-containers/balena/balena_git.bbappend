# Fixes: QA Issue: File /usr/bin/balena-engine in package balena contains reference to TMPDIR [buildpaths
INSANE_SKIP:${PN} += " buildpaths "
do_compile:prepend() {
    export GOFLAGS="-trimpath"
}

