SUMMARY = "Lightweight and flexible command-line JSON processor"
DESCRIPTION = "jq is like sed for JSON data, you can use it to slice and \
               filter and map and transform structured data with the same \
               ease that sed, awk, grep and friends let you play with text."
HOMEPAGE = "http://stedolan.github.io/jq/"
BUGTRACKER = "https://github.com/stedolan/jq/issues"
SECTION = "utils"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=244a1fb9cf472474a062d67069dec653"

DEPENDS = "flex-native bison-native"

SRC_URI = "http://stedolan.github.io/${BPN}/download/source/${BP}.tar.gz \
"
SRC_URI[md5sum] = "e3c75a4f805bb5342c9f4b3603fb248f"
SRC_URI[sha256sum] = "998c41babeb57b4304e65b4eb73094279b3ab1e63801b6b4bddd487ce009b39d"

inherit autotools

# Don't build documentation (generation requires ruby)
EXTRA_OECONF = "--disable-docs"
