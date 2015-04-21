# Don't start connman at boot because we start it in resin-init
INITSCRIPT_PACKAGES = ""
INITSCRIPT_NAME = ""
INITSCRIPT_PARAMS = ""

PR = "${INC_PR}.0"

do_configure_append () {
        # Disable the dnsproxy for systemd unit files.
        sed -i "s/ExecStart=.*/& --nodnsproxy/" ${S}/src/connman.service

	# Disable the dnsproxy for the init script.
	sed -i "s/\$DAEMON/\$DAEMON --nodnsproxy/" ${S}/../connman

}
