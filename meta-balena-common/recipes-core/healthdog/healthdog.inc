inherit cargo-dyn pkgconfig
DEPENDS += "systemd pkgconfig-native"

S = "${@d.getVar('UNPACKDIR') + '/git' if d.getVar('UNPACKDIR') else d.getVar('WORKDIR') + '/git'}"
