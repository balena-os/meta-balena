DESCRIPTION = "NOOBS for Raspberry Pi"
LICENSE = "custom"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE.noobs;md5=da9003fdc21a7bab51d486d8b1c11f60"

inherit deploy

PR="r0"
SRC_URI = "https://s3.amazonaws.com/resin-share/build_requirements/noobs-1.3.6.tar.xz;name=noobs;subdir=noobs \
	   file://LICENSE.noobs \
	   file://os.json \
	   file://partition_setup.sh \
	   file://partitions.json \
	   file://empty.tar.xz;unpack=false \
	  "
SRC_URI[noobs.md5sum] = "e92f71915864c266ebf9fb5d80d359eb"

COMPATIBLE_MACHINE = "raspberrypi"

S = "${WORKDIR}/noobs"


do_deploy() {
    install -d ${DEPLOYDIR}/${PN}
    install -d ${DEPLOYDIR}/${PN}/os
    install -d ${DEPLOYDIR}/${PN}/os/Resin

    for i in ${S}/* ; do
        cp -r $i ${DEPLOYDIR}/${PN}
    done

    cp -r ${WORKDIR}/LICENSE.noobs ${DEPLOYDIR}/${PN}
    cp -r ${WORKDIR}/os.json ${DEPLOYDIR}/${PN}/os/Resin
    cp -r ${WORKDIR}/partitions.json ${DEPLOYDIR}/${PN}/os/Resin
    cp -r ${WORKDIR}/partition_setup.sh ${DEPLOYDIR}/${PN}/os/Resin
    cp -r ${WORKDIR}/empty.tar.xz ${DEPLOYDIR}/${PN}/os/Resin
     sed -i 's/runinstaller\ quiet/runinstaller\ silentinstall\ quiet/g' ${DEPLOYDIR}/${PN}/recovery.cmdline

}


addtask deploy before do_package after do_install
do_deploy[dirs] += "${DEPLOYDIR}/${PN}"
PACKAGE_ARCH = "${MACHINE_ARCH}"

