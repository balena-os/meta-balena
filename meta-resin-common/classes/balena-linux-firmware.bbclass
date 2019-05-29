# Clean up versions of the iwlwifi firmware files based on API version by
# adding a task which cleans up the install directory after install and before
# package.
# 
# IWLWIFI_FW_TOCLEAN is used to activate what versions to cleanup.
#   For each version activated through IWLWIFI_FW_TOCLEAN, IWLWIFI_FW_MIN_API
#   needs to be specified as the minimum API version to be used when cleaning
#   the files.
# IWLWIFI_PATH defines where in D are the firmware files installed.
# IWLWIFI_REGEX is the regex defining how to parse the filename to extract
#   the version and the api.

python do_iwlwifi_firmware_clean() {
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
            minapi = minapi_all[version]
            if not minapi:
                bb.fatal("There is no minimum API version set for %s." %version)
            bb.note("Cleaning iwlwifi firmware version %s to minimum API version %s." %(version, minapi))
            left_fw = []
            for filename in os.listdir(path):
                m = re.match(regex, filename)
                if m and m.group(1) and m.group(2):
                    try:
                        parsed_minapi = int(minapi)
                        parsed_matched_version = int(m.group(2))
                    except:
                        parsed_minapi = minapi
                        parsed_matched_version = m.group(2)
                    if m.group(1) == version:
                        if parsed_matched_version < parsed_minapi:
                            filepath = os.path.join(path, filename)
                            bb.note("  Removing %s." %filename)
                            os.remove(filepath)
                        else:
                            left_fw.append(filename)
            for filename in left_fw:
                bb.note("  Leaving %s in place." %filename)
        else:
            bb.warn("IWLWIFI_FW_TOCLEAN activates %s but no corresponding IWLWIFI_FW_MIN_API was defined." %version)
}

python __anonymous() {
    vars = [ "IWLWIFI_FW_MIN_API" ]
    for v in vars:
        for flag in sorted((d.getVarFlags(v) or {}).keys()):
            d.appendVar('%s_VARDEPS' % (v), ' %s:%s' % (flag, d.getVarFlag(v, flag, False)))
}
do_iwlwifi_firmware_clean[vardeps] += "IWLWIFI_FW_MIN_API_VARDEPS"
addtask iwlwifi_firmware_clean after do_install before do_package
