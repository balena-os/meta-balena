DESCRIPTION = "Intel Edison DFU files for flashing"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit deploy

PR="r3"
SRC_URI = "file://edison_dnx_fwr.bin \
	   file://edison_dnx_osr.bin \
	   file://edison_ifwi-dbg-00.bin \
	   file://edison_ifwi-dbg-00-dfu.bin \
	   file://edison_ifwi-dbg-01.bin \
	   file://edison_ifwi-dbg-01-dfu.bin \
	   file://edison_ifwi-dbg-02.bin \
	   file://edison_ifwi-dbg-02-dfu.bin \
	   file://edison_ifwi-dbg-03.bin \
	   file://edison_ifwi-dbg-03-dfu.bin \
	   file://edison_ifwi-dbg-04.bin \
	   file://edison_ifwi-dbg-04-dfu.bin \
	   file://edison_ifwi-dbg-05.bin \
	   file://edison_ifwi-dbg-05-dfu.bin \
	   file://edison_ifwi-dbg-06.bin \
	   file://edison_ifwi-dbg-06-dfu.bin \
	   file://filter-dfu-out.js \
	   file://flashall.bat \
	   file://flashall.sh \
	   file://pft-config-edison.xml \
	   file://dfu-util.exe \
	   file://DFU-UTIL_0.8_COPYING \
	   file://FlashEdison.json \
	   file://helper.html \
	   file://Edison-arduino-blink-led.png \
	   file://Edison-arduino.png \
	   file://Edison-breakout-board.png \
	  "

COMPATIBLE_MACHINE = "edison"
DEPLOYMENT_DIRECTORY = "resin-edison"

do_deploy() {
    install -d ${DEPLOYDIR}/${DEPLOYMENT_DIRECTORY}

    for i in ${WORKDIR}/*.bin ; do
        cp -r $i ${DEPLOYDIR}/${DEPLOYMENT_DIRECTORY}
    done

    cp ${WORKDIR}/filter-dfu-out.js ${DEPLOYDIR}/${DEPLOYMENT_DIRECTORY}/
    cp ${WORKDIR}/flashall.bat ${DEPLOYDIR}/${DEPLOYMENT_DIRECTORY}/
    cp ${WORKDIR}/flashall.sh ${DEPLOYDIR}/${DEPLOYMENT_DIRECTORY}/
    cp ${WORKDIR}/pft-config-edison.xml ${DEPLOYDIR}/${DEPLOYMENT_DIRECTORY}/
    cp ${WORKDIR}/dfu-util.exe ${DEPLOYDIR}/${DEPLOYMENT_DIRECTORY}/
    cp ${WORKDIR}/DFU-UTIL_0.8_COPYING ${DEPLOYDIR}/${DEPLOYMENT_DIRECTORY}/
    cp ${WORKDIR}/FlashEdison.json ${DEPLOYDIR}/${DEPLOYMENT_DIRECTORY}/
    cp ${WORKDIR}/helper.html ${DEPLOYDIR}/${DEPLOYMENT_DIRECTORY}/
    cp ${WORKDIR}/Edison-arduino-blink-led.png ${DEPLOYDIR}/${DEPLOYMENT_DIRECTORY}/
    cp ${WORKDIR}/Edison-arduino.png ${DEPLOYDIR}/${DEPLOYMENT_DIRECTORY}/
    cp ${WORKDIR}/Edison-breakout-board.png ${DEPLOYDIR}/${DEPLOYMENT_DIRECTORY}/

}


addtask deploy before do_package after do_install
do_deploy[dirs] += "${DEPLOYDIR}/${DEPLOYMENT_DIRECTORY}"
PACKAGE_ARCH = "${MACHINE_ARCH}"
