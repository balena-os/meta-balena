#
# Resin netdata bbclass
#
# Copyright (C) 2018 resin.io
# Author: Matthew McGinn <matthew@resin.io>
#
# Licensed under the Apache-2.0 license, see COPYING.Apache-2.0 for details

# Resin netdata supported CPU architectures
#NETDATA_REPOSITORY_armv5 = "resin/armel-netdata"
#NETDATA_REPOSITORY_armv6 = "resin/rpi-netdata"
NETDATA_REPOSITORY_armv7a = "gin078/armv7hf-netdata"
NETDATA_REPOSITORY_armv7ve = "gin078/armv7hf-netdata"
#NETDATA_REPOSITORY_aarch64 = "resin/aarch64-netdata"
#NETDATA_REPOSITORY_x86 = "resin/i386-netdata"
NETDATA_REPOSITORY_x86-64 = "gin078/amd64-netdata"
#NETDATA_REPOSITORY_intel-quark = "resin/i386-nlp-netdata"

# Resin netdata default tag
NETDATA_TAG ?= "v0.0.1"
