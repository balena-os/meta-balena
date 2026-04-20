# Fixes ERROR: mobynit-git-r0 do_package_qa: QA Issue: File /boot/init in package mobynit contains reference to TMPDIR [buildpaths] 
INSANE_SKIP:${PN} += " buildpaths "
do_compile:prepend() {
    export GOFLAGS="-trimpath"
}
