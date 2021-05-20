#
# Balena supervisor bbclass
#
# Copyright (C) 2019 balenaLtd
# Author: Andrei Gherzan <andrei@resin.io>
#
# Licensed under the Apache-2.0 license, see COPYING.Apache-2.0 for details

# Balena supervisor supported CPU archtectures
SUPERVISOR_APP:armv5 ?= "armel-supervisor"
SUPERVISOR_APP:armv6 ?= "rpi-supervisor"
SUPERVISOR_APP:armv7a ?= "armv7hf-supervisor"
SUPERVISOR_APP:armv7ve ?= "armv7hf-supervisor"
SUPERVISOR_APP:aarch64 ?= "aarch64-supervisor"
SUPERVISOR_APP:x86 ?= "i386-supervisor"
SUPERVISOR_APP:x86-64 ?= "amd64-supervisor"
SUPERVISOR_APP:intel-quark ?= "i386-nlp-supervisor"

# Balena supervisor default version
SUPERVISOR_VERSION ?= "v12.11.16"
