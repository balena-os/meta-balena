# Add custom resin fields
OS_RELEASE_FIELDS_append = " RESIN_BOARD_REV META_RESIN_REV SLUG MACHINE VARIANT VARIANT_ID"

# Simplify VERSION output
VERSION = "${HOSTOS_VERSION}"

VARIANT = "${@bb.utils.contains('DEVELOPMENT_IMAGE','1','Development','Production',d)}"
VARIANT_ID = "${@bb.utils.contains('DEVELOPMENT_IMAGE','1','dev','prod',d)}"

python __anonymous () {
    import subprocess
    import json

    # Generate RESIN_BOARD_REV and META_RESIN_REV
    version = d.getVar("VERSION", True)
    bblayers = d.getVar("BBLAYERS", True)

    # Detect the path of meta-resin-common
    metaresincommonpath = filter(lambda x: x.endswith('meta-resin-common'), bblayers.split())
    if sys.version_info.major >= 3 :
         metaresincommonpath = list(metaresincommonpath)

    if metaresincommonpath:
        resinboardpath = os.path.join(metaresincommonpath[0], '../../')
        metaresinpath = os.path.join(metaresincommonpath[0], '../')

        cmd = 'git log -n1 --format=format:%h '
        resinboardrev = subprocess.Popen('cd ' + resinboardpath + ' ; ' + cmd, stdout=subprocess.PIPE, shell=True).communicate()[0]
        if sys.version_info.major >= 3 :
            resinboardrev = resinboardrev.decode()
        metaresinrev = subprocess.Popen('cd ' + metaresinpath + ' ; ' + cmd, stdout=subprocess.PIPE, shell=True).communicate()[0]
        if sys.version_info.major >= 3 :
            metaresinrev = metaresinrev.decode()

        if resinboardrev:
            d.setVar('RESIN_BOARD_REV', resinboardrev)
        if metaresinrev:
            d.setVar('META_RESIN_REV', metaresinrev)
    else:
        bb.warn("Cannot get the revisions of your repositories.")

    # Generate SLUG to be included in os-release
    machine = d.getVar("MACHINE", True)
    jsonfile = os.path.normpath(os.path.join(resinboardpath, '..', machine + ".json"))
    try:
        with open(jsonfile, 'r') as fd:
            machinejson = json.load(fd)
        slug = machinejson['slug']
        d.setVar('SLUG', slug)
    except Exception as e:
        bb.warn("os-release: Can't get the machine json so os-release won't include this information.")
}

#
# Add quotes around values not matching [A-Za-z0-9]*
# Failing to do so will confuse docker info
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
