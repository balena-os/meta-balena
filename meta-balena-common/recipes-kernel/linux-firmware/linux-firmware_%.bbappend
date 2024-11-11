PACKAGES =+ "${PN}-rtl8188eu"

FILES:${PN}-rtl8188eu = " \
    /lib/firmware/rtlwifi/rtl8188eu*.bin* \
    "

PACKAGES =+ "${PN}-iwlwifi-9260"

FILES:${PN}-iwlwifi-9260 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-9260-* \
    "

PACKAGES =+ "${PN}-iwlwifi-qu-b0-hr-b0"

FILES:${PN}-iwlwifi-qu-b0-hr-b0 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-Qu-b0-hr-b0-* \
    "

PACKAGES =+ "${PN}-ibt-19-0-4"

FILES:${PN}-ibt-19-0-4  = " \
    ${nonarch_base_libdir}/firmware/intel/ibt-19-0-4.doc* \
    ${nonarch_base_libdir}/firmware/intel/ibt-19-0-4.sfi* \
    "

PACKAGES =+ "${PN}-ath10k-qca6174"

FILES:${PN}-ath10k-qca6174 = " \
    ${nonarch_base_libdir}/firmware/ath10k/QCA6174/* \
"

PACKAGES =+ "${PN}-rtl8723b-bt"

FILES:${PN}-rtl8723b-bt = " \
    ${nonarch_base_libdir}/firmware/rtl_bt/rtl8723b_fw.bin* \
"

PACKAGES =+ "${PN}-iwlwifi-3168"

FILES:${PN}-iwlwifi-3168 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-3168-* \
"

PACKAGES =+ "${PN}-ibt-18-16-1"

FILES:${PN}-ibt-18-16-1  = " \
    ${nonarch_base_libdir}/firmware/intel/ibt-18-16-1.sfi* \
    ${nonarch_base_libdir}/firmware/intel/ibt-18-16-1.ddc* \
"

PACKAGES =+ "${PN}-ibt-41-41"

FILES:${PN}-ibt-41-41  = " \
    ${nonarch_base_libdir}/firmware/intel/ibt-0041-0041.ddc \
    ${nonarch_base_libdir}/firmware/intel/ibt-0041-0041.sfi \
"

LICENSE:${PN}-ibt-41-41 = "Firmware-ibt_firmware"
RDEPENDS:${PN}-ibt-41-41 = "${PN}-ibt-license"

PACKAGES =+ "${PN}-ralink-nic"

FILES:${PN}-ralink-nic = " \
    ${nonarch_base_libdir}/firmware/rtl_nic/rtl8168g-2.fw* \
"

PACKAGES =+ "${PN}-iwlwifi-3160"

FILES:${PN}-iwlwifi-3160 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-3160-17.ucode* \
"

PACKAGES =+ "${PN}-iwlwifi-cc-a0"

FILES:${PN}-iwlwifi-cc-a0 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-cc-a0-*.ucode* \
"

PACKAGES =+ "${PN}-iwlwifi-ty-a0"

FILES:${PN}-iwlwifi-ty-a0  = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-ty-a0-*.ucode \
    ${nonarch_base_libdir}/firmware/iwlwifi-ty-a0-*.pnvm \
"

LICENSE:${PN}-iwlwifi-ty-a0 = "Firmware-iwlwifi_firmware"
RDEPENDS:${PN}-iwlwifi-ty-a0 = "${PN}-iwlwifi-license"

# Skylake/6th Gen Core processors
# https://en.wikipedia.org/wiki/Skylake_(microarchitecture)#List_of_Skylake_processor_models
PACKAGES =+ "${PN}-i915-skl"

FILES:${PN}-i915-skl = " \
    ${nonarch_base_libdir}/firmware/i915/skl* \
    "

# Kaby Lake/14nm Skylake successor, Gen 7 desktop/mobile
# https://en.wikipedia.org/wiki/Kaby_Lake#List_of_7th_generation_Kaby_Lake_processors
PACKAGES =+ "${PN}-i915-kbl"

FILES:${PN}-i915-kbl = " \
    ${nonarch_base_libdir}/firmware/i915/kbl* \
    "

# Gemini Lake/Goldmont Plus, low-power 14nm Pentium/Celeron desktop and mobile
# https://en.wikipedia.org/wiki/Goldmont_Plus#List_of_Goldmont_Plus_processors
PACKAGES =+ "${PN}-i915-glk"

FILES:${PN}-i915-glk = " \
    ${nonarch_base_libdir}/firmware/i915/glk* \
    "

# Cannon Lake/10nm shrink of Kaby Lake, only the i3-8121U
# https://en.wikipedia.org/wiki/Cannon_Lake_(microprocessor)#List_of_Cannon_Lake_CPUs
PACKAGES =+ "${PN}-i915-cnl"

FILES:${PN}-i915-cnl = " \
    ${nonarch_base_libdir}/firmware/i915/cnl* \
    "

# Ice Lake/10nm 10th gen mobile and certain Xeons
# https://en.wikipedia.org/wiki/Ice_Lake_(microprocessor)#List_of_Ice_Lake_CPUs
PACKAGES =+ "${PN}-i915-icl"

FILES:${PN}-i915-icl = " \
    ${nonarch_base_libdir}/firmware/i915/icl* \
    "

# Comet Lake/14nm 10th Gen Core processors
# https://en.wikipedia.org/wiki/Comet_Lake_(microprocessor)#List_of_10th_generation_Comet_Lake_processors
PACKAGES =+ "${PN}-i915-cml"

FILES:${PN}-i915-cml = " \
    ${nonarch_base_libdir}/firmware/i915/cml* \
    "

# Broxton/cancelled Cherry Trail successor
# https://en.wikichip.org/wiki/intel/cores/broxton
PACKAGES =+ "${PN}-i915-bxt"

FILES:${PN}-i915-bxt = " \
    ${nonarch_base_libdir}/firmware/i915/bxt* \
    "

# Rocket Lake/14nm backport of Ice Lake, 11th Gen Core desktop processors w/ Xe graphics
# https://en.wikipedia.org/wiki/Rocket_Lake#List_of_11th_generation_Rocket_Lake_processors
PACKAGES =+ "${PN}-i915-rkl"

FILES:${PN}-i915-rkl = " \
    ${nonarch_base_libdir}/firmware/i915/rkl* \
    "

# Tiger Lake/10nm 11th gen mobile w/ Xe graphics
# https://en.wikipedia.org/wiki/Tiger_Lake#List_of_Tiger_Lake_CPUs
PACKAGES =+ "${PN}-i915-tgl"

FILES:${PN}-i915-tgl = " \
    ${nonarch_base_libdir}/firmware/i915/tgl* \
    "

# Elkhart Lake/10nm Atom server CPUs
# https://ark.intel.com/content/www/us/en/ark/products/codename/128825/products-formerly-elkhart-lake.html
PACKAGES =+ "${PN}-i915-ehl"

FILES:${PN}-i915-ehl = " \
    ${nonarch_base_libdir}/firmware/i915/ehl* \
    "

# Alder Lake/10nm successor to Tiger Lake, unreleased as of this commit
# https://en.wikichip.org/wiki/intel/microarchitectures/alder_lake
PACKAGES =+ "${PN}-i915-adl"

FILES:${PN}-i915-adl = " \
    ${nonarch_base_libdir}/firmware/i915/adl* \
    "

# First gen discrete graphics, unreleased as of this commit
PACKAGES =+ "${PN}-i915-dg1"

FILES:${PN}-i915-dg1 = " \
    ${nonarch_base_libdir}/firmware/i915/dg1* \
    "
PACKAGES =+ "${PN}-iwlwifi-quz-a0-hr-b0"

FILES:${PN}-iwlwifi-quz-a0-hr-b0 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-QuZ-a0-hr-b0-*.ucode* \
"

PACKAGES =+ "${PN}-iwlwifi-quz-a0-jf-b0"
FILES:${PN}-iwlwifi-quz-a0-jf-b0 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-QuZ-a0-jf-b0-*.ucode* \
"
