FILESEXTRAPATHS_append := ":${THISDIR}/files"

python() {
    from distutils.version import StrictVersion
    packageVersion = d.getVar('PV', True)
    srcURI = d.getVar('SRC_URI', True)
    packages = d.getVar('PACKAGES', True)
    if StrictVersion(packageVersion) >= StrictVersion('2.28') and StrictVersion(packageVersion) < StrictVersion('2.31'):
        # This patch was included in 2.31 so only apply it when needed
        d.setVar('SRC_URI', srcURI + ' ' + 'file://0001-libblkid-don-t-check-for-size-on-UBI-char-dev.patch')

    if StrictVersion(packageVersion) < StrictVersion('2.29.1'):
        d.setVar('FILES_util-linux-lsblk', '${bindir}/lsblk')

        # we only add to PACKAGES when it contains actual values
        # this is done because when building the resin image target, bitbake would typically run this code here multiple times and one
        # of this runs will result in an empty PACKAGES variable to which we add "util-linux-lsblk" after which bitbake will complain:
        #       NOTE: Resolving any missing task queue dependencies
        #       NOTE: multiple providers are available for runtime util-linux-lsblk (util-linux, util-linux-native)
        #       NOTE: consider defining aaa PREFERRED_RPROVIDER entry to match util-linux-lsblk
        if packages:
            d.setVar('PACKAGES', 'util-linux-lsblk' + ' ' + packages)
}

