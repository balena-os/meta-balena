# Extends the meta-oe `audit` recipe: enable the audisp syslog dispatcher, make
# the journal the only sink, and ship a static ruleset.
#
# A .bbappend rather than a second recipe because everything here lives under
# ${sysconfdir}/audit/, which `audit` already owns — a second recipe writing
# those paths would collide at rootfs assembly. `audit_%` survives version bumps.
#
# The configs are sed-ed in place rather than shipped, so this cannot drift from
# the plugin path/type/args of whatever audit version is built.

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# file:// unpacks to ${WORKDIR} on kirkstone, ${UNPACKDIR} on scarthgap.
SRC_URI += " \
    file://audit.rules \
"

do_install:append() {
    # audisp-syslog -> syslog(3) -> /dev/log -> systemd-journald
    sed -i 's/^active\s*=.*/active = yes/' \
        ${D}${sysconfdir}/audit/plugins.d/syslog.conf

    # The dispatcher above is the only transport, and balena-hostapp-extension
    # strips /var from the extension rootfs, so /var/log/audit/audit.log would
    # have neither readers nor a directory to live in.
    sed -i 's/^write_logs\s*=.*/write_logs = no/' \
        ${D}${sysconfdir}/audit/auditd.conf
    grep -q '^write_logs = no$' ${D}${sysconfdir}/audit/auditd.conf || \
        bbfatal "write_logs not set in auditd.conf: no line matched, audit.log would still be opened"

    # Installed as audit.rules, not rules.d/, because the stock auditd.service
    # loads exactly this path read-only at boot:
    #     ExecStartPost=/sbin/auditctl -R /etc/audit/audit.rules
    # augenrules cannot be used: it *writes* the compiled set back to
    # audit.rules, and the rootfs is read-only at runtime.
    install -m 0640 ${WORKDIR}/audit.rules \
        ${D}${sysconfdir}/audit/audit.rules
}
