#
# Resin supervisor bbclass
#
# Copyright (C) 2017 resin.io
# Author: Andrei Gherzan <andrei@resin.io>
#
# Licensed under the Apache-2.0 license, see COPYING.Apache-2.0 for details

# Resin supervisor supported CPU archtectures
SUPERVISOR_REPOSITORY_armv5 = "resin/armel-supervisor"
SUPERVISOR_REPOSITORY_armv6 = "resin/rpi-supervisor"
SUPERVISOR_REPOSITORY_armv7a = "resin/armv7hf-supervisor"
SUPERVISOR_REPOSITORY_armv7ve = "resin/armv7hf-supervisor"
SUPERVISOR_REPOSITORY_aarch64 = "resin/aarch64-supervisor"
SUPERVISOR_REPOSITORY_x86 = "resin/i386-supervisor"
SUPERVISOR_REPOSITORY_x86-64 = "resin/amd64-supervisor"
SUPERVISOR_REPOSITORY_intel-quark = "resin/i386-nlp-supervisor"

# Resin supervisor default tag
SUPERVISOR_TAG ?= "v7.19.7"
