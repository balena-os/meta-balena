# balenaOS uses openssh as SSH daemon but we still need utils from dropbear for
# keys migration. So have them in but without starting the services.
SYSTEMD_AUTO_ENABLE = "disable"

# We need dropbear to be able to migrate host keys in the update hooks
RCONFLICTS_${PN} = ""
