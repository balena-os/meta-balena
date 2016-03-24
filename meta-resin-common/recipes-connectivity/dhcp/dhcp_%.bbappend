# append a Google DNS (8.8.8.8) to the namservers received by DHCP

do_install_append() {
    sed -i '/^#* *append domain-name-servers .*;$/{s//append domain-name-servers 8.8.8.8;/;h};${x;/^$/{s//append domain-name-servers 8.8.8.8;/;H};x}' ${D}/etc/dhcp/dhclient.conf
}
