# The OPKG configure service disables itself at first boot which fails due to
# ro rootfs
SYSTEMD_SERVICE_${PN} = ""
