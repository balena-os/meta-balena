do_install_append_halium() {
    # libwayland-egl is provided by libhybris
    rm -f ${D}${libdir}/libwayland-egl*
}
