SUMMARY = "MyProject Additional files"
LICENSE = "CLOSED"
PR = "r1"    

SRC_URI = "file://my-rule1.rules \
"

do_install[nostamp] = "1"
do_unpack[nostamp] = "1"    

do_install () {
    echo "my-project install task invoked"
    install -d ${D}/etc/udev/rules.d
    install -m 0666 ${WORKDIR}/my-rule1.rules           ${D}/etc/udev/rules.d/my-rule1.rules
}    

FILES_${PN} += " \
     /etc/udev/rules.d/my-rule1.rules \
     "

PACKAGES = "${PN}"
PROVIDES = "rfs-my-project"