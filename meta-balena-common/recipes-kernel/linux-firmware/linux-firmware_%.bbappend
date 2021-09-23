# Cleanup iwlwifi firmware files
IWLWIFI_PATH = "lib/firmware"
IWLWIFI_REGEX = "^iwlwifi-([0-9a-zA-Z-]+)-([0-9]+).ucode$"

IWLWIFI_FW_MIN_API[7260] = "17"
IWLWIFI_FW_MIN_API[7265] = "17"
IWLWIFI_FW_MIN_API[7265D] = "29"
IWLWIFI_FW_MIN_API[8000C] = "34"
IWLWIFI_FW_MIN_API[8265] = "34"

inherit balena-linux-firmware

python() {
    import os,re

    source_dir = d.getVar('S', True)
    destination = d.getVar('D', True)
    if destination is None:
        return
    install_path = os.path.join(destination, d.getVar('IWLWIFI_PATH',True))
    package_name = d.getVar('PN', True)
    package_version = d.getVar('PV', True)
    regex = d.getVar('IWLWIFI_REGEX', True)
    minapi_all = d.getVarFlags('IWLWIFI_FW_MIN_API') or {}
    if not os.path.exists(source_dir):
        return
    for chipset, minapi in minapi_all.items():
        minapi = int(minapi_all[chipset] or 0)
        bb.note('Limiting iwlwifi firmware for chipset {} to minimum API version {}.'.format(chipset, minapi))
        package_files = []
        for filename in os.listdir(source_dir):
            m = re.match(regex, filename)
            if m and m.group(1) and m.group(2):
                matched_chipset = m.group(1)
                matched_version = int(m.group(2))
                if matched_chipset == chipset:
                    filepath = os.path.join(d.getVar('IWLWIFI_PATH'), filename)
                    if matched_version >= minapi:
                        package_files.append(filepath)
                    else:
                        bb.note('{} < {}, skipping packaging'.format(filename, minapi))

        d.setVar('FILES_{}-iwlwifi-{}'.format(package_name, chipset.lower()), ' '.join(package_files))
}

PACKAGES =+ "${PN}-rtl8188eu"

FILES_${PN}-rtl8188eu = " \
    /lib/firmware/rtlwifi/rtl8188eu*.bin* \
    "

PACKAGES =+ "${PN}-iwlwifi-9260"

FILES_${PN}-iwlwifi-9260 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-9260-* \
    "

PACKAGES =+ "${PN}-iwlwifi-qu-b0-hr-b0"

FILES_${PN}-iwlwifi-qu-b0-hr-b0 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-Qu-b0-hr-b0-* \
    "

PACKAGES =+ "${PN}-ibt-19-0-4"

FILES_${PN}-ibt-19-0-4  = " \
    ${nonarch_base_libdir}/firmware/intel/ibt-19-0-4.doc* \
    ${nonarch_base_libdir}/firmware/intel/ibt-19-0-4.sfi* \
    "

PACKAGES =+ "${PN}-ath10k-qca6174"

FILES_${PN}-ath10k-qca6174 = " \
    ${nonarch_base_libdir}/firmware/ath10k/QCA6174/* \
"

PACKAGES =+ "${PN}-rtl8723b-bt"

FILES_${PN}-rtl8723b-bt = " \
    ${nonarch_base_libdir}/firmware/rtl_bt/rtl8723b_fw.bin* \
"

PACKAGES =+ "${PN}-iwlwifi-3168"

FILES_${PN}-iwlwifi-3168 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-3168-* \
"

PACKAGES =+ "${PN}-ibt-18-16-1"

FILES_${PN}-ibt-18-16-1  = " \
    ${nonarch_base_libdir}/firmware/intel/ibt-18-16-1.sfi* \
    ${nonarch_base_libdir}/firmware/intel/ibt-18-16-1.ddc* \
"

PACKAGES =+ "${PN}-ralink-nic"

FILES_${PN}-ralink-nic = " \
    ${nonarch_base_libdir}/firmware/rtl_nic/rtl8168g-2.fw* \
"

PACKAGES =+ "${PN}-iwlwifi-3160"

FILES_${PN}-iwlwifi-3160 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-3160-17.ucode* \
"

PACKAGES =+ "${PN}-iwlwifi-cc-a0"

FILES_${PN}-iwlwifi-cc-a0 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-cc-a0-48.ucode* \
"

# Skylake/6th Gen Core processors
# https://en.wikipedia.org/wiki/Skylake_(microarchitecture)#List_of_Skylake_processor_models
PACKAGES =+ "${PN}-i915-skl"

FILES_${PN}-i915-skl = " \
    ${nonarch_base_libdir}/firmware/i915/skl* \
    "

# Kaby Lake/14nm Skylake successor, Gen 7 desktop/mobile
# https://en.wikipedia.org/wiki/Kaby_Lake#List_of_7th_generation_Kaby_Lake_processors
PACKAGES =+ "${PN}-i915-kbl"

FILES_${PN}-i915-kbl = " \
    ${nonarch_base_libdir}/firmware/i915/kbl* \
    "

# Gemini Lake/Goldmont Plus, low-power 14nm Pentium/Celeron desktop and mobile
# https://en.wikipedia.org/wiki/Goldmont_Plus#List_of_Goldmont_Plus_processors
PACKAGES =+ "${PN}-i915-glk"

FILES_${PN}-i915-glk = " \
    ${nonarch_base_libdir}/firmware/i915/glk* \
    "

# Cannon Lake/10nm shrink of Kaby Lake, only the i3-8121U
# https://en.wikipedia.org/wiki/Cannon_Lake_(microprocessor)#List_of_Cannon_Lake_CPUs
PACKAGES =+ "${PN}-i915-cnl"

FILES_${PN}-i915-cnl = " \
    ${nonarch_base_libdir}/firmware/i915/cnl* \
    "

# Ice Lake/10nm 10th gen mobile and certain Xeons
# https://en.wikipedia.org/wiki/Ice_Lake_(microprocessor)#List_of_Ice_Lake_CPUs
PACKAGES =+ "${PN}-i915-icl"

FILES_${PN}-i915-icl = " \
    ${nonarch_base_libdir}/firmware/i915/icl* \
    "

# Comet Lake/14nm 10th Gen Core processors
# https://en.wikipedia.org/wiki/Comet_Lake_(microprocessor)#List_of_10th_generation_Comet_Lake_processors
PACKAGES =+ "${PN}-i915-cml"

FILES_${PN}-i915-cml = " \
    ${nonarch_base_libdir}/firmware/i915/cml* \
    "

# Broxton/cancelled Cherry Trail successor
# https://en.wikichip.org/wiki/intel/cores/broxton
PACKAGES =+ "${PN}-i915-bxt"

FILES_${PN}-i915-bxt = " \
    ${nonarch_base_libdir}/firmware/i915/bxt* \
    "

# Rocket Lake/14nm backport of Ice Lake, 11th Gen Core desktop processors w/ Xe graphics
# https://en.wikipedia.org/wiki/Rocket_Lake#List_of_11th_generation_Rocket_Lake_processors
PACKAGES =+ "${PN}-i915-rkl"

FILES_${PN}-i915-rkl = " \
    ${nonarch_base_libdir}/firmware/i915/rkl* \
    "

# Tiger Lake/10nm 11th gen mobile w/ Xe graphics
# https://en.wikipedia.org/wiki/Tiger_Lake#List_of_Tiger_Lake_CPUs
PACKAGES =+ "${PN}-i915-tgl"

FILES_${PN}-i915-tgl = " \
    ${nonarch_base_libdir}/firmware/i915/tgl* \
    "

# Elkhart Lake/10nm Atom server CPUs
# https://ark.intel.com/content/www/us/en/ark/products/codename/128825/products-formerly-elkhart-lake.html
PACKAGES =+ "${PN}-i915-ehl"

FILES_${PN}-i915-ehl = " \
    ${nonarch_base_libdir}/firmware/i915/ehl* \
    "

# Alder Lake/10nm successor to Tiger Lake, unreleased as of this commit
# https://en.wikichip.org/wiki/intel/microarchitectures/alder_lake
PACKAGES =+ "${PN}-i915-adl"

FILES_${PN}-i915-adl = " \
    ${nonarch_base_libdir}/firmware/i915/adl* \
    "

# First gen discrete graphics, unreleased as of this commit
PACKAGES =+ "${PN}-i915-dg1"

FILES_${PN}-i915-dg1 = " \
    ${nonarch_base_libdir}/firmware/i915/dg1* \
    "
