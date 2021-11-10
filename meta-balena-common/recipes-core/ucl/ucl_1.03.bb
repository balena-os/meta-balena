HOMEPAGE = "http://www.oberhumer.com/opensource/ucl/"
SUMMARY = "Data compression library"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=dfeaf3dc4beef4f5a7bdbc35b197f39e"

SRC_URI = " \
    http://www.oberhumer.com/opensource/ucl/download/ucl-1.03.tar.gz \
    file://0001-configure.ac-Fix-with-current-autoconf.patch \
    file://0002-acinclude.m4-Provide-missing-macros.patch"

SRC_URI[md5sum] = "852bd691d8abc75b52053465846fba34"
SRC_URI[sha256sum] = "b865299ffd45d73412293369c9754b07637680e5c826915f097577cd27350348"

inherit autotools

CFLAGS:append = " -std=c90"

BBCLASSEXTEND = "native"
