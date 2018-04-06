# Copyright 2017 Resinio Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# Sanity checks for resinOS builds
#
def resinos_build_configuration():
	success = True
	if d.getVar('PACKAGE_CLASSES', True) != "package_ipk":
		bb.warn("ResinOS distro depends on opkg packages (ipk). Make sure PACKAGE_CLASSES is set on package_ipk.")
	if d.getVar('DOCKER_STORAGE', True):
		bb.warn("DOCKER_STORAGE variable was replaced by BALENA_STORAGE. Please update your build configuration.")
	if d.getVar('BALENA_STORAGE', True) not in ['aufs', 'overlay2']:
		bb.error("ResinOS supports only aufs and overlay2 as balena storage drivers.")
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
