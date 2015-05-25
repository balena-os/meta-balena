# BUG in meta-parallella
# Use DEPLOYDIR not DEPLOY_DIR_IMAGE so sstate can package the artifacts
do_deploy() {
    install -d ${DEPLOYDIR}/bitstreams
    for i in $(ls ${S}/fpga/bitstreams/ | grep parallella_.*_headless.*\.bit\.bin); do
        install ${S}/fpga/bitstreams/$i ${DEPLOYDIR}/bitstreams
    done
}
do_deploy[dirs] += "${DEPLOYDIR}/bitstreams"
