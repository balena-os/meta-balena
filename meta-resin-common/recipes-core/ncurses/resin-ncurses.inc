SRC_URI = "ftp://invisible-island.net/${BPN}/current/${BP}-${REVISION}.tgz"

do_configure_prepend() {
    export cf_cv_working_poll=yes
    #Remove ${includedir} from CPPFLAGS, need for cross compile
    sed -i 's#-I${cf_includedir}##g' ${S}/configure || die "sed CPPFLAGS"

    # The --enable-pc-files requires PKG_CONFIG_LIBDIR existed
    mkdir -p ${PKG_CONFIG_LIBDIR}
}

do_install_append() {
    if [ -d "${D}${includedir}/ncurses" ]; then
        for f in `find ${D}${includedir}/ncurses -name "*.h"`
        do
            f=`basename $f`
            test -e ${D}${includedir}/$f && continue
                ln -sf ncurses/$f ${D}${includedir}/$f
        done
    fi
}
