# Support for compressed kernel modules
#
# Provides mechanism for compressing all the kernel modules in the kernel-module-*
# packages using the tool defined in MODULE_COMPRESS. Currently only supported for
# gzip and xz (as modprobe supports these too).
#
# MODULE_COMPRESS =
#   "gzip"  - compress using gzip [default]
#   "xz"    - compress using xz
#   ""      - don't compress
#
# Author: Andrei Gherzan <andrei@resin.io>

MODULE_COMPRESS ?= "gzip"

python () {
    '''Add the corresponding native depends for each supported MODULE_COMPRESS'''

    modulecompress = d.getVar('MODULE_COMPRESS', True)
    depends = d.getVar('DEPENDS', True)

    if not modulecompress:
        return

    if modulecompress == "gzip":
        depends = depends + " gzip-native"
    elif modulecompress == "xz":
        depends = depends + " xz-native"
    else:
        bb.fatal("compress_kernel_modules: currently only gzip and xz are supported for kernel modules compress defined by MODULE_COMPRESS.")
    d.setVar('DEPENDS', depends)
}

python compress_all_kernel_modules() {
    import os, fnmatch, subprocess
    from itertools import chain

    modulecompress = d.getVar('MODULE_COMPRESS', True)
    pkgdest = d.getVar('PKGDEST', True)
    pkgd = d.getVar('PKGD', True)

    if not modulecompress:
        return

    # Support for gzip and xz
    if modulecompress == "gzip":
        compresscmd = "gzip --rsyncable -n -f --".split()
    elif modulecompress == "xz":
        compresscmd = "xz -f --".split()
    else:
        bb.fatal("compress-kernel-modules: currently only gzip and xz are supported for kernel modules compress defined by MODULE_COMPRESS.")

    # Compress all found ko files in packages and package-split
    kmodulepattern = "*.ko"
    for root, dirs, files in chain.from_iterable(os.walk(path) for path in [pkgdest, pkgd]):
        for file in fnmatch.filter(files, kmodulepattern):
            cmd = compresscmd + [os.path.join(root, file)]
            try:
                output = subprocess.check_output(cmd, stderr=subprocess.STDOUT)
            except subprocess.CalledProcessError as e:
                bb.error("compress-kernel-modules: '%s' compress command failed with %s (%s)" % (cmd, e.returncode, e.output))
}

PACKAGEFUNCS += "compress_all_kernel_modules"
