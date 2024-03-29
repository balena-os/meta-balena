inherit balena-linux-firmware

# Cleanup iwlwifi firmware files
IWLWIFI_PATH = "lib/firmware"
IWLWIFI_REGEX = "^iwlwifi-([0-9a-zA-Z-]+)-([0-9]+).ucode$"
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
