#
# Sanity checks for resinOS builds
#
# Copyright (C) 2017 resin.io
# Author: Andrei Gherzan <andrei@resin.io>
#
# Licensed under the Apache-2.0 license, see COPYING.Apache-2.0 for details

def resinos_build_configuration():
	success = True
	if d.getVar('PACKAGE_CLASSES', True) != "package_ipk":
		bb.warn("ResinOS distro depends on opkg packages (ipk). Make sure PACKAGE_CLASSES is set on package_ipk.")
	if d.getVar('DOCKER_STORAGE', True) not in ['aufs', 'overlay2']:
		bb.error("ResinOS supports only aufs and overlay2 as docker storage drivers.")
		success = False
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

REQUIRED_DISTRO_FEATURES += " systemd"
