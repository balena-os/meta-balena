# we do not use this file in any of our supported boards and we need to remove it to fix the following error:
# ERROR: modemmanager-1.24.2-r0 do_package_qa: QA Issue: /usr/share/ModemManager/modem-setup.available.d/0000 contained in package
# modemmanager requires 0000_modemmanager:, but no providers found in RDEPENDS_modemmanager? [file-rdeps]
# ERROR: modemmanager-1.24.2-r0 do_package_qa: QA run found fatal errors. Please consider fixing them.
do_install_append() {
    rm ${D}${datadir}/ModemManager/modem-setup.available.d/0000:0000
}
