# Add custom resin fields
OS_RELEASE_FIELDS_append = " RESIN_BOARD_REV META_RESIN_REV SLUG MACHINE"

# Simplify VERSION output
VERSION = "${HOSTOS_VERSION}"

python __anonymous () {
    import subprocess
    import json

    # Generate RESIN_BOARD_REV and META_RESIN_REV
    version = d.getVar("VERSION", True)
    bblayers = d.getVar("BBLAYERS", True)

    # Detect the path of meta-resin-common
    metaresincommonpath = list(filter(lambda x: x.endswith('meta-resin-common'), bblayers.split()))

    if metaresincommonpath:
        resinboardpath = os.path.join(metaresincommonpath[0], '../../')
        metaresinpath = os.path.join(metaresincommonpath[0], '../')

        cmd = 'git log -n1 --format=format:%h '
        resinboardrev = subprocess.Popen('cd ' + resinboardpath + ' ; ' + cmd, stdout=subprocess.PIPE, shell=True).communicate()[0].decode()
        metaresinrev = subprocess.Popen('cd ' + metaresinpath + ' ; ' + cmd, stdout=subprocess.PIPE, shell=True).communicate()[0].decode()

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
