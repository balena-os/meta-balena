FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"

# Fix DNS issues
SRC_URI_append = " \
    file://0001-fix-res-init-detection.patch \
    file://0002-Move-res_init-call-to-inner-openvpn_getaddrinfo-loop.patch \
    "
