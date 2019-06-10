# This task is defined in meta-rust. We over-ride it until
# https://github.com/meta-rust/meta-rust/issues/240
# is fixed upstream
def llvm_features_from_tune(d):
    f = []
    feat = d.getVar('TUNE_FEATURES')
    if not feat:
        return []
    feat = frozenset(feat.split())

    mach_overrides = d.getVar('MACHINEOVERRIDES')
    if not mach_overrides:
        return []
    mach_overrides = frozenset(mach_overrides.split(':'))

    if 'vfpv4' in feat:
        f.append("+vfp4")
    if 'vfpv3' in feat:
        f.append("+vfp3")
    if 'vfpv3d16' in feat:
        f.append("+d16")

    if 'vfpv2' in feat or 'vfp' in feat:
        f.append("+vfp2")

    if 'neon' in feat:
        f.append("+neon")

    if 'aarch64' in feat:
        f.append("+v8")

    if 'mips32' in feat:
        f.append("+mips32")

    if 'mips32r2' in feat:
        f.append("+mips32r2")

    v7=frozenset(['armv7a', 'armv7r', 'armv7m', 'armv7ve'])
    if (not mach_overrides.isdisjoint(v7)) or (not feat.isdisjoint(v7)):
        f.append("+v7")
    if ('armv6' in mach_overrides) or ('armv6' in feat):
        f.append("+v6")

    if 'dsp' in feat:
        f.append("+dsp")

    if 'thumb' in feat:
        if d.getVar('ARM_THUMB_OPT') is "thumb":
            if (not mach_overrides.isdisjoint(v7)) or (not feat.isdisjoint(v7)):
                f.append("+thumb2")
            f.append("+thumb-mode")

    if 'cortexa5' in feat:
        f.append("+a5")
    if 'cortexa7' in feat:
        f.append("+a7")
    if 'cortexa9' in feat:
        f.append("+a9")
    if 'cortexa15' in feat:
        f.append("+a15")
    if 'cortexa17' in feat:
        f.append("+a17")

    return f
