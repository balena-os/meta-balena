SUMMARY = "Peak linux driver"

LICENSE = "GPLv2 & LGPLv2.1"
LIC_FILES_CHKSUM = " \
    file://LICENSE.gpl;md5=75859989545e37968a99b631ef42722e \
    file://LICENSE.lgpl;md5=1803fa9c2c3ce8cb06b4861d75310742 \
    "

SRC_URI[sha256sum] = "f1692a78a948f3847abdd14689ae24f9eb00ead9f3bf2b6f875f5d905fb3cdcd"
SRC_URI = " \
    https://www.peak-system.com/fileadmin/media/linux/files/peak-linux-driver-${PV}.tar.gz \
"

DEPENDS = "ca-certificates-native coreutils-native curl-native jq-native"

inherit module

S = "${WORKDIR}/peak-linux-driver-${PV}"

EXTRA_OEMAKE:append = " KERNEL_LOCATION=${STAGING_KERNEL_DIR}"

# the driver can either be built as chardev or netdev
# we want to build both and ship them at the same time
# even though only one can be loaded at any moment
FLAVOURS = "chardev netdev"

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
    MISC_DIR="${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/misc"

    for FLAVOUR in ${FLAVOURS}
    do
        cd "driver-${FLAVOUR}"
        oe_runmake install_module DEPMOD=echo DESTDIR=${D} KERNEL_VERSION=${KERNEL_VERSION}
        mv "${MISC_DIR}/pcan.ko" "${MISC_DIR}/pcan_${FLAVOUR}.ko"
        cd ..
    done
}

do_sign () {
    if [ "${SIGN}" != "true" ]; then
        return 0
    fi

    # Sign the modules
    TO_SIGN=$(mktemp)

    for FLAVOUR in ${FLAVOURS}
    do
        echo "${B}/driver-${FLAVOUR}/pcan.ko" >> "${TO_SIGN}"
    done

    export CURL_CA_BUNDLE="${STAGING_DIR_NATIVE}/etc/ssl/certs/ca-certificates.crt"

    for FILE_TO_SIGN in $(cat "${TO_SIGN}")
    do
        REQUEST_FILE=$(mktemp)
        RESPONSE_FILE=$(mktemp)
        echo "{\"key_id\": \"${SIGN_KMOD_KEY_ID}\", \"payload\": \"$(base64 -w 0 ${FILE_TO_SIGN})\"}" > "${REQUEST_FILE}"
        curl --fail "${SIGN_API}/kmod/sign" -X POST -H "Content-Type: application/json" -H "X-API-Key: ${SIGN_API_KEY}" -d "@${REQUEST_FILE}" > "${RESPONSE_FILE}"
        jq -r .signed < "${RESPONSE_FILE}" | base64 -d > "${FILE_TO_SIGN}.signed"
        mv "${FILE_TO_SIGN}.signed" "${FILE_TO_SIGN}"
        rm -f "${REQUEST_FILE}" "${RESPONSE_FILE}"
    done

    rm -f "${TO_SIGN}"
}

addtask sign before do_install after do_compile
