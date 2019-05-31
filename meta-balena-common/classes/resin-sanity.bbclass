#
# Sanity checks for resinOS builds
#
# Copyright (C) 2017 resin.io
# Author: Andrei Gherzan <andrei@resin.io>
#
# Licensed under the Apache-2.0 license, see COPYING.Apache-2.0 for details

BALENA_DEPRECATED_COLLECTIONS = " \
	resin-common:balena-common \
	"

def resinos_build_configuration():
    success = True
    if d.getVar('PACKAGE_CLASSES', True) != "package_ipk":
        bb.warn("ResinOS distro depends on opkg packages (ipk). Make sure PACKAGE_CLASSES is set on package_ipk.")
    if d.getVar('DOCKER_STORAGE', True):
        bb.warn("DOCKER_STORAGE variable was replaced by BALENA_STORAGE. Please update your build configuration.")
    if d.getVar('BALENA_STORAGE', True) not in ['aufs', 'overlay2']:
        bb.error("ResinOS supports only aufs and overlay2 as balena storage drivers.")
        success = False
    if d.getVar('RESIN_CONNECTABLE', True) or d.getVar('RESIN_CONNECTABLE_SERVICES', True) or d.getVar('RESIN_CONNECTABLE_ENABLE_SERVICES', True):
        bb.warn("Your build configuration uses RESIN_CONNECTABLE* variables. These variables are no longer used. There is only one type of resinOS image type which is unconnected by default. The os-config tool is used to configure the resinOS image for connectivity to a resin instance.")
    if d.getVar('BALENA_DEPRECATED_YOCTO_LAYER', True) == "1":
        bb.warn("Your build configuration is using a poky layer that has been deprecated by meta-balena. Please update and use a newer poky version.")
    for deprecation in d.getVar('BALENA_DEPRECATED_COLLECTIONS').split():
        deprecated_collection = deprecation.split(':')[0]
        new_collection = deprecation.split(':')[1] if len(deprecation.split(':')) == 2 else ''
        if deprecated_collection in d.getVar('BBFILE_COLLECTIONS'):
            bb.warn("meta-%s is a deprecated layer. Please replace it in your bblayers.conf by meta-%s." % (deprecated_collection, new_collection if new_collection else 'the respective new balena layer'))
    return success

python resinos_sanity_handler() {
    if d.getVar('RESINOS_SANITY_SKIP', True) == "1":
        bb.warn('ResinOS specific sanity checks were skipped.')
        return
    if not resinos_build_configuration():
        bb.fatal("ResinOS sanity checks failed. See above.")
}

addhandler resinos_sanity_handler
resinos_sanity_handler[eventmask] = "bb.event.BuildStarted"
