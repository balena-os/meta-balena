SUMMARY = "Peak linux driver"

LICENSE = "GPLv2 & LGPLv2.1"
LIC_FILES_CHKSUM = " \
    file://LICENSE.gpl;md5=75859989545e37968a99b631ef42722e \
    file://LICENSE.lgpl;md5=1803fa9c2c3ce8cb06b4861d75310742 \
    "

SRC_URI[sha256sum] = "7e0cc997d4d3838a60a3634d54774d8234070b91db14dcc48ed15ae2ea4d163e"
SRC_URI = " \
    https://www.peak-system.com/fileadmin/media/linux/files/peak-linux-driver-${PV}.tar.gz \
"

inherit module sign-kmod

S = "${WORKDIR}/peak-linux-driver-${PV}"

EXTRA_OEMAKE:append = " KERNEL_LOCATION=${STAGING_KERNEL_DIR}"

# the driver can either be built as chardev or netdev
# we want to build both and ship them at the same time
# even though only one can be loaded at any moment
FLAVOURS = "chardev netdev"
python __anonymous () {
    artifacts = []
    for flavour in d.getVar('FLAVOURS').split():
        artifacts.append(os.path.join(d.getVar('B'), "driver-" + flavour, "pcan.ko" ))
    d.setVar('SIGNING_ARTIFACTS', ' '.join(artifacts))
}

do_configure:append() {
    for FLAVOUR in ${FLAVOURS}
    do
        cp -a driver "driver-${FLAVOUR}"
    done
}

do_compile() {
    unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS

    for FLAVOUR in ${FLAVOURS}
    do
        cd "driver-${FLAVOUR}"
        oe_runmake KERNEL_PATH=${STAGING_KERNEL_DIR}   \
            KERNEL_VERSION=${KERNEL_VERSION}    \
            CC="${KERNEL_CC}" LD="${KERNEL_LD}" \
            AR="${KERNEL_AR}" \
            O=${STAGING_KERNEL_BUILDDIR} \
            KBUILD_EXTRA_SYMBOLS="${KBUILD_EXTRA_SYMBOLS}" \
            "${FLAVOUR}"
        cd ..
    done
}

do_install() {
    MISC_DIR="${D}${libdir}/modules/${KERNEL_VERSION}/misc"
    MODULE_FILENAME="pcan.ko"

    for FLAVOUR in ${FLAVOURS}
    do
        TMP_DIR=$(mktemp -d -p .)
        cp -a "driver-${FLAVOUR}/"* "${TMP_DIR}/"
        cd "${TMP_DIR}"
        if [ -f "${MODULE_FILENAME}.signed" ]; then
            mv "${MODULE_FILENAME}.signed" "${MODULE_FILENAME}"
        fi
        oe_runmake install_module DEPMOD=echo DESTDIR=${D}${prefix} KERNEL_VERSION=${KERNEL_VERSION}
        mv "${MISC_DIR}/${MODULE_FILENAME}" "${MISC_DIR}/pcan_${FLAVOUR}.ko"
        cd ..
        rm -rf "${TMP_DIR}"
    done
}

addtask sign_kmod before do_install after do_compile
