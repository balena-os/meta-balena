#
# Balena supervisor bbclass
#
# Copyright (C) 2019 balenaLtd
# Author: Andrei Gherzan <andrei@resin.io>
#
# Licensed under the Apache-2.0 license, see COPYING.Apache-2.0 for details

# Balena supervisor supported CPU archtectures
SUPERVISOR_REPOSITORY:armv5 ?= "balena/armel-supervisor"
SUPERVISOR_REPOSITORY:armv6 ?= "balena/rpi-supervisor"
SUPERVISOR_REPOSITORY:armv7a ?= "balena/armv7hf-supervisor"
SUPERVISOR_REPOSITORY:armv7ve ?= "balena/armv7hf-supervisor"
SUPERVISOR_REPOSITORY:aarch64 ?= "balena/aarch64-supervisor"
SUPERVISOR_REPOSITORY:x86 ?= "balena/i386-supervisor"
SUPERVISOR_REPOSITORY:x86-64 ?= "balena/amd64-supervisor"
SUPERVISOR_REPOSITORY_intel-quark ?= "balena/i386-nlp-supervisor"

# Balena supervisor default tag
SUPERVISOR_TAG ?= "v12.11.16"
