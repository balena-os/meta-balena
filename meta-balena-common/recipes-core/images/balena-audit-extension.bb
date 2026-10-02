DESCRIPTION = "Audit hostapp extension: the Linux Audit userspace, wired to the host journal"
LICENSE = "MIT"

inherit balena-hostapp-extension

IMAGE_INSTALL:append = " auditd audispd-plugins"

# Everything under /etc that the payload needs, and nothing else:
#   audit/                      config and the ruleset
#   tmpfiles.d/audit-volatile.conf
#                               creates /var/log/audit, which auditd opens at
#                               startup and exits 6 without. /var/log is a
#                               symlink to a tmpfs, so it cannot come from the
#                               overlay and has to be created each boot.
#   multi-user.target.wants/    the enablement symlink. Not a package file:
#                               systemd's preset pass writes it during do_rootfs,
#                               and this runs afterwards, so it is deletable here
#                               and auditd would ship installed but disabled.
AUDIT_ETC_KEEP ?= " \
    audit \
    tmpfiles.d/audit-volatile.conf \
    systemd/system/multi-user.target.wants/auditd.service \
"

# we want to keep from /etc only AUDIT_ETC_KEEP
remove_unnecessary_files() {
    rm -rf ${IMAGE_ROOTFS}/run ${IMAGE_ROOTFS}/var

    keep="${WORKDIR}/audit-etc-keep"
    rm -rf "$keep"

    # saving directory from AUDIT_ETC_KEEP to keep
    for p in ${AUDIT_ETC_KEEP}; do
        mkdir -p "$keep/$(dirname "$p")"
        cp -a "${IMAGE_ROOTFS}/etc/$p" "$keep/$p"
    done

    rm -rf ${IMAGE_ROOTFS}/etc
    mkdir -p ${IMAGE_ROOTFS}/etc
    cp -a "$keep/." ${IMAGE_ROOTFS}/etc/
    rm -rf "$keep"
}

HOSTAPP_EXTENSION_LABEL_REQUIRES_REBOOT = "1"
