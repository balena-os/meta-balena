SUMMARY = "Generated Balena Firmware Package Group (from linux-firmware analysis)"
DESCRIPTION = "This file enforce a list of essential firmware on the target, it also exclude non essential firmware from the image."
LICENSE = "Apache-2.0"

PR = "r0"

inherit packagegroup

# all of those don't exists anymore: linux-firmware-iwlwifi-3160-10 linux-firmware-iwlwifi-3160-12 linux-firmware-iwlwifi-3160-13 linux-firmware-iwlwifi-3160-16 linux-firmware-iwlwifi-3160-7 linux-firmware-iwlwifi-3160-8 linux-firmware-iwlwifi-3160-9, they are replaced by linux-firmware-iwlwifi-3160

# not shipped any more : linux-firmware-iwlwifi-6000g2a-5 linux-firmware-iwlwifi-6000g2b-5 linux-firmware-iwlwifi-6050-4 linux-firmware-iwlwifi-so-a0

# linux-firmware-wl1251 is empty but is shipped in linux-firmware-wl12xx

# not found packages:
#  linux-firmware-ibt-40-41 

# Essential firmware packages (Connectivity and other essential categories)
ESSENTIAL_FIRMWARE_PACKAGES = " \
    linux-firmware-ar3k \
    linux-firmware-ar5523 \
    linux-firmware-ar9170 \
    linux-firmware-ath10k \
    linux-firmware-ath10k-qca6174 \
    linux-firmware-ath11k \
    linux-firmware-ath12k \
    linux-firmware-ath3k \
    linux-firmware-ath6k \
    linux-firmware-ath9k \
    linux-firmware-bcm-0bb4-0306 \
    linux-firmware-bcm43143 \
    linux-firmware-bcm43236b \
    linux-firmware-bcm43241b0 \
    linux-firmware-bcm43241b4 \
    linux-firmware-bcm43241b5 \
    linux-firmware-bcm43242a \
    linux-firmware-bcm4329 \
    linux-firmware-bcm4329-fullmac \
    linux-firmware-bcm4330 \
    linux-firmware-bcm4334 \
    linux-firmware-bcm43340 \
    linux-firmware-bcm4335 \
    linux-firmware-bcm43362 \
    linux-firmware-bcm4339 \
    linux-firmware-bcm43430 \
    linux-firmware-bcm43430a0 \
    linux-firmware-bcm43455 \
    linux-firmware-bcm4350 \
    linux-firmware-bcm4350c2 \
    linux-firmware-bcm4354 \
    linux-firmware-bcm4356 \
    linux-firmware-bcm4356-pcie \
    linux-firmware-bcm43569 \
    linux-firmware-bcm43570 \
    linux-firmware-bcm4358 \
    linux-firmware-bcm43602 \
    linux-firmware-bcm4366b \
    linux-firmware-bcm4366c \
    linux-firmware-bcm4371 \
    linux-firmware-bcm4373 \
    linux-firmware-bcm43xx \
    linux-firmware-bcm43xx-hdr \
    linux-firmware-bnx2 \
    linux-firmware-bnx2x \
    linux-firmware-carl9170 \
    linux-firmware-cw1200 \
    linux-firmware-ibt-11-5 \
    linux-firmware-ibt-12-16 \
    linux-firmware-ibt-17 \
    linux-firmware-ibt-18-16-1 \
    linux-firmware-ibt-19-0-4 \
    linux-firmware-ibt-20 \
    linux-firmware-ibt-41-41 \
    linux-firmware-ibt-hw-37-7 \
    linux-firmware-ibt-hw-37-8 \
    linux-firmware-ibt-misc \
    linux-firmware-ice \
    linux-firmware-ice-enhanced \
    linux-firmware-iwlwifi-135-6 \
    linux-firmware-iwlwifi-3160 \
    linux-firmware-iwlwifi-3168 \
    linux-firmware-iwlwifi-6000-4 \
    linux-firmware-iwlwifi-6000g2a-6 \
    linux-firmware-iwlwifi-6000g2b-6 \
    linux-firmware-iwlwifi-6050-5 \
    linux-firmware-iwlwifi-7260 \
    linux-firmware-iwlwifi-7265 \
    linux-firmware-iwlwifi-7265d \
    linux-firmware-iwlwifi-8000c \
    linux-firmware-iwlwifi-8265 \
    linux-firmware-iwlwifi-9000 \
    linux-firmware-iwlwifi-9260 \
    linux-firmware-iwlwifi-cc-a0 \
    linux-firmware-iwlwifi-misc \
    linux-firmware-iwlwifi-qu-b0-hr-b0 \
    linux-firmware-iwlwifi-quz-a0-hr-b0 \
    linux-firmware-iwlwifi-quz-a0-jf-b0 \
    linux-firmware-iwlwifi-ty-a0 \
    linux-firmware-liquidio \
    linux-firmware-mediatek \
    linux-firmware-mellanox \
    linux-firmware-mt7601u \
    linux-firmware-mt7650 \
    linux-firmware-mt76x2 \
    linux-firmware-netronome \
    linux-firmware-olpc \
    linux-firmware-pcie8897 \
    linux-firmware-pcie8997 \
    linux-firmware-phanfw \
    linux-firmware-prestera \
    linux-firmware-qca \
    linux-firmware-qcom-qcm2290-wifi \
    linux-firmware-qcom-qrb4210-wifi \
    linux-firmware-qcom-sdm845-modem \
    linux-firmware-qed \
    linux-firmware-qla2xxx \
    linux-firmware-ralink \
    linux-firmware-ralink-nic \
    linux-firmware-rs9113 \
    linux-firmware-rs9116 \
    linux-firmware-rtl-nic \
    linux-firmware-rtl8168 \
    linux-firmware-rtl8188 \
    linux-firmware-rtl8188eu \
    linux-firmware-rtl8192ce \
    linux-firmware-rtl8192cu \
    linux-firmware-rtl8192su \
    linux-firmware-rtl8723 \
    linux-firmware-rtl8723b-bt \
    linux-firmware-rtl8761 \
    linux-firmware-rtl8821 \
    linux-firmware-rtl8822 \
    linux-firmware-sd8686 \
    linux-firmware-sd8688 \
    linux-firmware-sd8787 \
    linux-firmware-sd8797 \
    linux-firmware-sd8801 \
    linux-firmware-sd8887 \
    linux-firmware-sd8897 \
    linux-firmware-sd8997 \
    linux-firmware-usb8997 \
    linux-firmware-vt6656 \
    linux-firmware-wl12xx \
    linux-firmware-wl18xx \
    linux-firmware-wlcommon \
    "

# Non-essential firmware packages (GPU, Audio, Video, Misc)
# These are excluded from the image by default
NONESSENTIAL_FIRMWARE_PACKAGES = " \
    linux-firmware-adsp-sst \
    linux-firmware-amdgpu \
    linux-firmware-amlogic-vdec \
    linux-firmware-amphion-vpu \
    linux-firmware-cirrus \
    linux-firmware-cnm \
    linux-firmware-i915 \
    linux-firmware-imx-sdma-imx6q \
    linux-firmware-imx-sdma-imx7d \
    linux-firmware-lt9611uxc \
    linux-firmware-mediatek \
    linux-firmware-microchip \
    linux-firmware-moxa \
    linux-firmware-nvidia-gpu \
    linux-firmware-nvidia-tegra \
    linux-firmware-nvidia-tegra-k1 \
    linux-firmware-nxp-mc \
    linux-firmware-nxp8987-sdio \
    linux-firmware-nxp8997-common \
    linux-firmware-nxp9098-common \
    linux-firmware-nxpiw416-sdio \
    linux-firmware-nxpiw612-sdio \
    linux-firmware-powervr \
    linux-firmware-qat \
    linux-firmware-qca \
    linux-firmware-qcom-adreno-a2xx \
    linux-firmware-qcom-adreno-a3xx \
    linux-firmware-qcom-adreno-a4xx \
    linux-firmware-qcom-adreno-a530 \
    linux-firmware-qcom-adreno-a630 \
    linux-firmware-qcom-adreno-a650 \
    linux-firmware-qcom-adreno-a660 \
    linux-firmware-qcom-adreno-a702 \
    linux-firmware-qcom-apq8016-modem \
    linux-firmware-qcom-apq8016-wifi \
    linux-firmware-qcom-apq8096-adreno \
    linux-firmware-qcom-apq8096-audio \
    linux-firmware-qcom-apq8096-modem \
    linux-firmware-qcom-qcm2290-adreno \
    linux-firmware-qcom-qcm2290-audio \
    linux-firmware-qcom-qcm2290-modem \
    linux-firmware-qcom-qrb4210-adreno \
    linux-firmware-qcom-qrb4210-audio \
    linux-firmware-qcom-qrb4210-compute \
    linux-firmware-qcom-qrb4210-modem \
    linux-firmware-qcom-sc8280xp-lenovo-x13s-adreno \
    linux-firmware-qcom-sc8280xp-lenovo-x13s-audio \
    linux-firmware-qcom-sc8280xp-lenovo-x13s-compat \
    linux-firmware-qcom-sc8280xp-lenovo-x13s-compute \
    linux-firmware-qcom-sc8280xp-lenovo-x13s-sensors \
    linux-firmware-qcom-sdm845-adreno \
    linux-firmware-qcom-sdm845-audio \
    linux-firmware-qcom-sdm845-compute \
    linux-firmware-qcom-sdm845-modem \
    linux-firmware-qcom-sdm845-thundercomm-db845c-sensors \
    linux-firmware-qcom-sm8250-adreno \
    linux-firmware-qcom-sm8250-audio \
    linux-firmware-qcom-sm8250-compute \
    linux-firmware-qcom-sm8250-thundercomm-rb5-sensors \
    linux-firmware-qcom-venus-1.8 \
    linux-firmware-qcom-venus-4.2 \
    linux-firmware-qcom-venus-5.2 \
    linux-firmware-qcom-venus-5.4 \
    linux-firmware-qcom-venus-6.0 \
    linux-firmware-qcom-vpu-1.0 \
    linux-firmware-qcom-vpu-2.0 \
    linux-firmware-radeon \
    linux-firmware-rockchip-dptx \
    linux-firmware-ti-keystone \
    linux-firmware-xc4000 \
    linux-firmware-xc5000 \
    linux-firmware-xc5000c \
    "

# Only essential firmware packages are included in the image
RDEPENDS:${PN} = "${ESSENTIAL_FIRMWARE_PACKAGES}"

BAD_RECOMMENDATIONS:append = " ${NONESSENTIAL_FIRMWARE_PACKAGES}"
