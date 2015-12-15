#
# intel nuc
#

IMAGE_FSTYPES_append_nuc = " resin-sdcard"

# Do not support live USB stick
NOISO_nuc = "1"
NOHDD_nuc = "1"

# Customize resin-sdcard
RESIN_IMAGE_BOOTLOADER_nuc = "grub-efi"
RESIN_BOOT_PARTITION_FILES_nuc = " \
    bootx64.efi:/EFI/BOOT/ \
    grub.cfg:/EFI/BOOT/ \
    bzImage-nuc.bin:/vmlinuz \
    "
