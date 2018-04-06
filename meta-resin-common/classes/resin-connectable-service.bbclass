# Copyright 2016 Resinio Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
