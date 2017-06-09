#
# Sanity checks for resinOS builds
#
# Copyright (C) 2017 resin.io
# Author: Andrei Gherzan <andrei@resin.io>
#
# Licensed under the Apache-2.0 license, see COPYING.Apache-2.0 for details

def resinos_build_configuration(fatals):
	if d.getVar('PACKAGE_CLASSES', True) != "package_ipk":
		bb.warn("ResinOS distro depends on opkg packages (ipk). Make sure PACKAGE_CLASSES is set on package_ipk.")

python resinos_sanity_handler() {
	f = []
	if d.getVar('RESINOS_SANITY_SKIP', True) == "1":
		bb.warn('ResinOS specific sanity checks were skipped.')
		return
	resinos_build_configuration(f)
	if (f):
		bb.fatal("ResinOS sanity checks failed. See above.")
}

addhandler resinos_sanity_handler
resinos_sanity_handler[eventmask] = "bb.event.BuildStarted"
