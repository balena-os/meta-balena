require go-common.inc

FILESEXTRAPATHS:prepend := "${FILE_DIRNAME}/go-1.21:${FILE_DIRNAME}/go-1.20:${FILE_DIRNAME}/go-1.19:${FILE_DIRNAME}/go-1.18:"

LIC_FILES_CHKSUM = "file://LICENSE;md5=5d4950ecb7b26d2c5e4e7b4e0dd74707"

SRC_URI += "\
    file://0001-allow-CC-and-CXX-to-have-multiple-words.patch \
    file://0002-cmd-go-make-content-based-hash-generation-less-pedan.patch \
    file://0003-allow-GOTOOLDIR-to-be-overridden-in-the-environment.patch \
    file://0004-ld-add-soname-to-shareable-objects.patch \
    file://0005-make.bash-override-CC-when-building-dist-and-go_boot.patch \
    file://0006-cmd-dist-separate-host-and-target-builds.patch \
    file://0007-cmd-go-make-GOROOT-precious-by-default.patch \
    file://0008-use-GOBUILDMODE-to-set-buildmode.patch \
    file://0009-Revert-cmd-go-make-sure-CC-and-CXX-are-absolute.patch \
    file://0001-exec.go-do-not-write-linker-flags-into-buildids.patch \
    file://0001-src-cmd-dist-buildgo.go-do-not-hardcode-host-compile.patch \
    file://0010-net-Fix-issue-with-DNS-not-being-updated.patch  \
    file://CVE-2022-27664.patch \
    file://0001-net-http-httputil-avoid-query-parameter-smuggling.patch \
    file://CVE-2022-41715.patch \
    file://CVE-2022-41717.patch \
    file://CVE-2022-2879.patch \
    file://CVE-2022-41720.patch \
    file://CVE-2022-41723.patch \
    file://cve-2022-41724.patch \
    file://add_godebug.patch \
    file://cve-2022-41725.patch \
    file://CVE-2022-41722.patch \
    file://CVE-2023-24537.patch \
    file://CVE-2023-24534.patch \
    file://CVE-2023-24538_1.patch \
    file://CVE-2023-24538_2.patch \
    file://CVE-2023-24540.patch \
    file://CVE-2023-24539.patch \
    file://CVE-2023-29404.patch \
    file://CVE-2023-29405.patch \
    file://CVE-2023-29402.patch \
    file://CVE-2023-29400.patch \
    file://CVE-2023-29406.patch \
    file://CVE-2023-24536_1.patch \
    file://CVE-2023-24536_2.patch \
    file://CVE-2023-24536_3.patch \
    file://CVE-2023-24531_1.patch \
    file://CVE-2023-24531_2.patch \
    file://CVE-2023-29409.patch \
    file://CVE-2023-39319.patch \
    file://CVE-2023-39318.patch \
    file://CVE-2023-39326.patch \
"
SRC_URI[main.sha256sum] = "a1a48b23afb206f95e7bbaa9b898d965f90826f6f1d1fc0c1d784ada0cd300fd"

# Upstream don't believe it is a signifiant real world issue and will only
# fix in 1.17 onwards where we can drop this.
# https://github.com/golang/go/issues/30999#issuecomment-910470358
CVE_CHECK_IGNORE += "CVE-2021-29923"

# This are specific to Microsoft Windows
CVE_CHECK_IGNORE += "CVE-2022-41716 CVE-2023-45283 CVE-2023-45284"
