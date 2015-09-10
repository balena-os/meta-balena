#
# Fix parsing on other boards
#
# The recipe has a compatible machine only for odroid-ux3 and then SRCREV is defined
# again only for odroid-ux3. So this recipe will pe parsed by other boards too for which
# SRCREV won't be available triggering:
#
# ERROR: ExpansionError during parsing linux-odroid_3.10.bb: Failure expanding variable
# do_populate_sysroot: ExpansionError: Failure expanding variable SRCPV, expression was
# ${@bb.fetch2.get_srcrev(d)} which triggered exception FetchError: Fetcher failure for
# URL: 'git://github.com/hardkernel/linux.git;branch=master'. Please set a valid SRCREV
# for url ['SRCREV_default_pn-linux-odroid', 'SRCREV_default', 'SRCREV_pn-linux-odroid',
# 'SRCREV'] (possible key names are git://github.com/hardkernel/linux.git;branch=master,
# or use a ;rev=X URL parameter)
COMPATIBLE_MACHINE = "odroid-ux3"
