PACKAGES =+ "${PN}-rtl8188eu"

FILES_${PN}-rtl8188eu = " \
    /lib/firmware/rtlwifi/rtl8188eu*.bin \
    "

# Cleanup iwlwifi firmware files
IWLWIFI_PATH = "lib/firmware"
IWLWIFI_REGEX = "^iwlwifi-([0-9a-zA-Z]+)-([0-9]+).ucode$"
IWLWIFI_FW_TOCLEAN ?= " \
    7260 \
    7265 \
    7265D \
    8000C \
    8265 \
"
IWLWIFI_FW_MIN_API[7260] = "17"
IWLWIFI_FW_MIN_API[7265] = "17"
IWLWIFI_FW_MIN_API[7265D] = "29"
IWLWIFI_FW_MIN_API[8000C] = "34"
IWLWIFI_FW_MIN_API[8265] = "34"

python do_iwlwifi_firmware_clean() {
    """ Cleans up versions of the iwlwifi firmware files based on API version
    IWLWIFI_FW_TOCLEAN is used to activated what versions to cleanup.
    For each version activated through IWLWIFI_FW_TOCLEAN, IWLWIFI_FW_MIN_API
    needs to be specified as the minimum API version to be used when cleaning
    the files.
    IWLWIFI_PATH defines where in D are the firmware files installed.
    IWLWIFI_REGEX is the regex defining how to parse the filename to extract
    the version and the api.
    """

    import os,re

    path = os.path.join(d.getVar("D",True), d.getVar("IWLWIFI_PATH",True))
    regex = d.getVar("IWLWIFI_REGEX", True)
    versions = d.getVar("IWLWIFI_FW_TOCLEAN", True)
    minapi_all = d.getVarFlags("IWLWIFI_FW_MIN_API") or {}
    if not versions:
        bb.note("No iwlwifi firmware configured to clean in IWLWIFI_FIRMWARE_CLEAN.")
        return
    for version in versions.split():
        if version in minapi_all:
            bb.note("Cleaning iwlwifi firmware version %s." %version)
            minapi = minapi_all[version]
            for filename in os.listdir(path):
                m = re.match(regex, filename)
                if m:
                    if m.group(1) == version and m.group(2) < minapi:
                        filepath = os.path.join(path, filename)
                        bb.note("Removing %s." %filepath)
                        os.remove(filepath)
        else:
            bb.warn("IWLWIFI_FW_TOCLEAN activates %s but no corresponding IWLWIFI_FW_MIN_API was defined." %version)
}
addtask iwlwifi_firmware_clean after do_install before do_package
