inherit deploy

# Add custom resin fields
OS_RELEASE_FIELDS_append = " RESIN_BOARD_REV META_RESIN_REV SLUG MACHINE VARIANT VARIANT_ID"

# Simplify VERSION output
VERSION = "${HOSTOS_VERSION}"

VARIANT = "${@bb.utils.contains('DEVELOPMENT_IMAGE','1','Development','Production',d)}"
VARIANT_ID = "${@bb.utils.contains('DEVELOPMENT_IMAGE','1','dev','prod',d)}"

#
# Add quotes around values not matching [A-Za-z0-9]*
# Failing to do so will confuse the container engine
#
python do_fix_quotes () {
    import re
    lines = open(d.expand('${B}/os-release'), 'r').readlines()
    with open(d.expand('${B}/os-release'), 'w') as f:
        for line in lines:
            field = line.split('=')[0].strip()
            value = line.split('=')[1].strip()
            match = re.match(r"^[A-Za-z0-9]*$", value)
            match_quoted = re.match(r"^\".*\"$", value)
            if not match and not match_quoted:
                value = '"' + value + '"'
            f.write('{0}={1}\n'.format(field, value))
}
addtask fix_quotes after do_compile before do_install

do_deploy() {
    # Issue #906
    # Make the os-release available in the deploy directory as well so we can
    # include it in the boot partition
    install -m 644 ${D}/etc/os-release ${DEPLOYDIR}/os-release
}
addtask do_deploy before do_package after do_install
