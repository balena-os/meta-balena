# kernel-devsrc recipe tries to copy the arch syscall tools unconditionally.
# These tools were added only from 4.10 so trying this on older kernel versions
# will make the build fail.
# This was fixed in poky but the fix is only included from warrior on. See
# d5abdf023bbdd32cb2a35cb40e828127dd50ea3a.
do_install_prepend () {
    # Workaround
    echo "# Please ignore this file" > ${S}/arch/arm/tools/syscall.ignore
}
do_install_append () {
    # Workaround cleanup
    rm ${S}/arch/arm/tools/syscall.ignore
}
