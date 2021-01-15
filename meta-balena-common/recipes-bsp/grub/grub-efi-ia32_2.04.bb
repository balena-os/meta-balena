require recipes-bsp/grub/grub-efi_2.04.bb

FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"

EXTRA_OECONF += "--with-platform=i386-efi"

do_mkstandalone() {
    bbwarn "Running do_mkstandalone grub-efi-ia32"
}

addtask mkstandalone before do_install after do_compile

do_mkstandalone_append_class-target() {
    :
}

FILES_${PN} = "${libdir}/grub/i386-efi \
               ${datadir}/grub \
               "
