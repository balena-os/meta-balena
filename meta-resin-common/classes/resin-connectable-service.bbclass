# resin-connectable-service bbclass
#
# Author: Andrei Gherzan <andrei@resin.io>

python __anonymous() {
    # Enable/disable systemd services listed in RESIN_CONNECTABLE_SERVICES based on
    # RESIN_CONNECTABLE_ENABLE_SERVICES

    pn = d.getVar('PN', True)
    services = d.getVar('RESIN_CONNECTABLE_SERVICES', True).split()
    resin_connectable = d.getVar('RESIN_CONNECTABLE', True)
    resin_connectable_enable_services = d.getVar('RESIN_CONNECTABLE_ENABLE_SERVICES', True)

    if resin_connectable == '1' and pn in services:
        if resin_connectable_enable_services == '1':
            d.setVar('SYSTEMD_AUTO_ENABLE', 'enable')
        else:
            d.setVar('SYSTEMD_AUTO_ENABLE', 'disable')

    # Inject post install script for resin connectable configuration file
    postinst_resin_connectable =  ('if [ -n "$D" ]; then\n'
                           '            for rservice in ${RESIN_CONNECTABLE_SERVICES}; do\n'
                           '                if [ "${PN}" = "$rservice" ]; then\n'
                           '                    for service in ${SYSTEMD_SERVICE_${PN}}; do\n'
                           '                        mkdir -p $D/etc\n'
                           '                        echo "$service" >> $D${sysconfdir}/resin-connectable.conf\n'
                           '                    done\n'
                           '                    break\n'
                           '                fi\n'
                           '            done\n'
                           '        fi\n')
    postinst = d.getVar('pkg_postinst_%s' % pn, True)
    if not postinst:
        postinst = '#!/bin/sh\n'
    postinst += postinst_resin_connectable
    d.setVar('pkg_postinst_%s' % pn, postinst)
}
systemd_populate_packages[vardeps] += "RESIN_CONNECTABLE_ENABLE_SERVICES"
