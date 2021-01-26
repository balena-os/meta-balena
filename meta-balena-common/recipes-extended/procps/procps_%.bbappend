
ALLOW_EMPTY_${PN} = "1"
FILES_${PN} = ""
ALTERNATIVE_${PN} = ""

python procps_binpackages () {
    def pkg_hook(f, pkg, file_regex, output_pattern, modulename):
        pn = d.getVar('PN')
        d.appendVar('RRECOMMENDS_%s' % pn, ' %s' % pkg)

        if d.getVar('ALTERNATIVE_' + pkg):
            return
        if d.getVarFlag('ALTERNATIVE_LINK_NAME', modulename):
            d.setVar('ALTERNATIVE_' + pkg, modulename)

    bindirs = sorted(list(set(d.expand("${base_sbindir} ${base_bindir} ${bindir}").split())))
    for dir in bindirs:
        do_split_packages(d, root=dir,
                          file_regex=r'(.*)', output_pattern='${PN}-%s',
                          description='${PN} %s',
                          hook=pkg_hook, extra_depends='${PN}-libprocps', allow_links=False, prepend=False)

    # There are some symlinks for some binaries which we have ignored
    # above. Add them to the package owning the binary they are
    # pointing to
    extras = {}
    dvar = d.getVar('PKGD')
    for root in bindirs:
        for walkroot, dirs, files in os.walk(dvar + root):
            for f in files:
                file = os.path.join(walkroot, f)
                if not os.path.islink(file):
                    continue

                pkg = os.path.basename(os.readlink(file))
                extras[pkg] = extras.get(pkg, '') + ' ' + file.replace(dvar, '', 1)

    pn = d.getVar('PN')
    for pkg, links in extras.items():
        of = d.getVar('FILES_' + pn + '-' + pkg)
        links = of + links
        d.setVar('FILES_' + pn + '-' + pkg, links)
}

# we must execute before update-alternatives PACKAGE_PREPROCESS_FUNCS
PACKAGE_PREPROCESS_FUNCS =+ "procps_binpackages "

PACKAGES_DYNAMIC = "^${PN}-.*"

python procps_libpackages() {
    do_split_packages(d, root=d.getVar('libdir'), file_regex=r'^lib(.*)\.so\..*$',
                      output_pattern='${PN}-lib%s',
                      description='${PN} lib%s',
                      extra_depends='', prepend=True, allow_links=True)
}

PACKAGESPLITFUNCS =+ "procps_libpackages"

FILES_${PN}-sysctl += " ${sysconfdir}/sysctl* "
