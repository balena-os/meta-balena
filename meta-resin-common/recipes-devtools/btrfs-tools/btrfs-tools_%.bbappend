FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"

# for btrfs-tools versions older than 4.5.1 we need to still apply the following patch:
python() {
    from distutils.version import LooseVersion
    packageVersion = d.getVar('PV', True)
    srcURI = d.getVar('SRC_URI', True)
    if LooseVersion(packageVersion) < LooseVersion("4.5.1"):
        d.setVar('SRC_URI', srcURI + ' ' + 'file://0001-btrfs-progs-utils-make-sure-set_label_mounted-uses-c.patch')
}
