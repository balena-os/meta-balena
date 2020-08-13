DEPENDS = "bats-native"

do_runbats() {
    bbnote "Running ${PN} tests..."
    export PATH="${STAGING_DIR_NATIVE}/usr/libexec:$PATH"
    find ${WORKDIR} -name *.bats -print0 | xargs -n1 -0 ${STAGING_DIR_NATIVE}/usr/bin/bats
}

addtask runbats before do_package after do_install
