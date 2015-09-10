FILESEXTRAPATHS_prepend_odroid-c1 := "${THISDIR}/${PN}:"

SRC_URI_append_odroid-c1 = " \
    file://boot-from-part1.patch;patchdir=${WORKDIR} \
    "

do_deploy_append_odroid-c1 () {
    install ${WORKDIR}/boot.ini ${DEPLOYDIR}/boot.ini
}

# Fix max recursive bug:
# ERROR: ExpansionError during parsing u-boot-hardkernel_2011.03.bb: Failure expanding
# variable SRCPV, expression was ${@bb.fetch2.get_srcrev(d)} which triggered exception
# RuntimeError: maximum recursion depth exceeded in __instancecheck__
PV = "v2011.03+${SRCREV}"
