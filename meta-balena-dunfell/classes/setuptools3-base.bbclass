#
# Copyright OpenEmbedded Contributors
#
# SPDX-License-Identifier: MIT
#

DEPENDS_append_class-target = " python3-native python3"
DEPENDS_append_class-nativesdk = " python3-native python3"
RDEPENDS_${PN}_append_class-target = " python3-core"

export STAGING_INCDIR
export STAGING_LIBDIR

# LDSHARED is the ld *command* used to create shared library
export LDSHARED  = "${CCLD} -shared"
# LDXXSHARED is the ld *command* used to create shared library of C++
# objects
export LDCXXSHARED  = "${CXX} -shared"
# CCSHARED are the C *flags* used to create objects to go into a shared
# library (module)
export CCSHARED  = "-fPIC -DPIC"
# LINKFORSHARED are the flags passed to the $(CC) command that links
# the python executable
export LINKFORSHARED = "${SECURITY_CFLAGS} -Xlinker -export-dynamic"

FILES_${PN} += "${PYTHON_SITEPACKAGES_DIR}"
FILES_${PN}-staticdev += "${PYTHON_SITEPACKAGES_DIR}/*.a"
FILES_${PN}-dev += "${PYTHON_SITEPACKAGES_DIR}/*.la"

inherit python3native python3targetconfig
