# Fixes the following build error in Wrynose:
#     balena-extension-runtime-1.1.0+git-r0 do_package_qa: QA Issue: File /usr/bin/balena-extension-manager in package balena-extension-runtime contains reference to TMPDIR [buildpaths]
INSANE_SKIP:${PN} += " buildpaths "
do_compile:prepend() {
    export GOFLAGS="-trimpath"
}

