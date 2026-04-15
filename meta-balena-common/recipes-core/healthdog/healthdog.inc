inherit cargo-dyn
DEPENDS += "systemd pkgconfig-native"

S = "${@d.getVar('UNPACKDIR') + '/git' if d.getVar('UNPACKDIR') else d.getVar('WORKDIR') + '/git'}"
