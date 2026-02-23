SUMMARY = "Fast Log processor and Forwarder"
DESCRIPTION = "Fluent Bit is a data collector, processor and  \
forwarder for Linux. It supports several input sources and \
backends (destinations) for your data. \
"

HOMEPAGE = "http://fluentbit.io"
BUGTRACKER = "https://github.com/fluent/fluent-bit/issues"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=2ee41112a44fe7014dce33e26468ba93"
SECTION = "net"

#SRCREV = "3fdd42c6f2ec732ee7107cd1dfa0d3193750ac1d"
SRCREV = "4854f38c7c8095f29718071535e73a0a5d4e6694"
SRC_URI = "git://github.com/fluent/fluent-bit;nobranch=1;protocol=https"

S = "${WORKDIR}/git"
DEPENDS = "zlib bison-native flex-native"
INSANE_SKIP:${PN}-dev += "dev-elf"

# Use CMake 'Unix Makefiles' generator
OECMAKE_GENERATOR ?= "Unix Makefiles"

# Host related setup
EXTRA_OECMAKE += "-DGNU_HOST=${HOST_SYS} "

# Disable LuaJIT and filter_lua support
EXTRA_OECMAKE += "-DFLB_LUAJIT=Off -DFLB_FILTER_LUA=Off "

# Disable Library and examples
EXTRA_OECMAKE += "-DFLB_SHARED_LIB=Off -DFLB_EXAMPLES=Off "

DEPENDS += "libyaml openssl curl zstd "

inherit cmake systemd

SYSTEMD_SERVICE:${PN} = "fluent-bit.service"
TARGET_CC_ARCH:append = " ${SELECTED_OPTIMIZATION}"
