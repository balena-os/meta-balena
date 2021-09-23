DEPENDS += "xz-native"

fakeroot do_firmware_compression () {
    if [ "${FIRMWARE_COMPRESSION}" = "1" ]; then
        bbnote "Compressing firmware files"
        find "${D}${nonarch_base_libdir}/firmware" -type l -exec sh -c 'target=$(readlink "$0"); ln -sf "${target}.xz" "$0"; mv "$0" "$0".xz' {} \;
        find "${D}${nonarch_base_libdir}/firmware" -path "*/amd-ucode" -prune -o -type f -print -exec xz -C crc32 {} \;
    fi
}
addtask firmware_compression after do_install before do_package
addtask firmware_compression after do_install before do_populate_sysroot
do_unpack[vardeps] = 'FIRMWARE_COMPRESSION'
