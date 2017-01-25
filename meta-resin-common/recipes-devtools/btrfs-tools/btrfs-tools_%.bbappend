FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"

# for btrfs-tools older than 4.6 we still need to apply the folowing patch:
python() {
    packageVersion = d.getVar('PV', True)
    srcURI = d.getVar('SRC_URI', True)
    if packageVersion < '4.6':
        d.setVar('SRC_URI', srcURI + ' ' + 'file://0001-btrfs-progs-utils-make-sure-set_label_mounted-uses-c.patch')
}
