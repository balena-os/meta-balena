# Add MIPS arch support in goarch.bbclass (is missing in rocko) but needed by
# the recipes we have in the common layer
HOST_GOMIPS = "${@go_map_mips(d.getVar('HOST_ARCH'), d.getVar('TUNE_FEATURES'), d)}"
TARGET_GOMIPS = "${@go_map_mips(d.getVar('TARGET_ARCH'), d.getVar('TUNE_FEATURES'), d)}"
 
def go_map_mips(a, f, d):
    import re
    if a == 'mips' or a == 'mipsel':
        if 'fpu-hard' in f:
            return 'hardfloat'
        else:
            return 'softfloat'
    return ''
