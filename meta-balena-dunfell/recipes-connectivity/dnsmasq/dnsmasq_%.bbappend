FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

# upstream patch copied from this commit
# http://thekelleys.org.uk/gitweb/?p=dnsmasq.git;a=commit;h=3052ce208acf602f0163166dcefb7330d537cedb
# fixed upstream in v2.81rc1
SRC_URI += "file://0001-SIOCGSTAMP-is-defined-in-linux-sockios.h-not-asm-soc.patch"

