#ifndef HEADER_ENV_RESIN_H
#define HEADER_ENV_RESIN_H

/*
 * Assumes defined:
 *     resin_kernel_load_addr - kernel load address as we use the same
 *                              to load the env file
 *     resin_root_part        - existing in the env file to import (optional)
 *     resin_flasher_skip     - if set to 1 by integration layer, skips flasher detection (optional)
 * Defines:
 *     resin_set_kernel_root  - needs to be integrated with board
 *                              specific configuration
 *     resin_kernel_root      - the root kernel argument
 *     resin_dev_type         - device type from where we boot (e.g. mmc, usb etc.)
 *     resin_dev_index        - device index to be used at boot
 */

#include <config_resin.h>

#define RESIN_ENV \
       "resin_env_file=" __stringify(RESIN_ENV_FILE) "\0" \
       "resin_flasher_flag_file=" __stringify(RESIN_FLASHER_FLAG_FILE) "\0" \
       "resin_image_flag_file=" __stringify(RESIN_IMAGE_FLAG_FILE) "\0" \
       "resin_uboot_devices=" __stringify(RESIN_UBOOT_DEVICES) "\0" \
       "resin_boot_part=" __stringify(RESIN_BOOT_PART) "\0" \
       "resin_root_part=" __stringify(RESIN_DEFAULT_ROOT_PART) "\0" \
       "resin_flasher_skip=0 \0" \
       \
       "resin_find_root_part_uuid=" \
               "part uuid ${resin_dev_type} ${resin_dev_index}:${resin_root_part} resin_root_part_uuid\0" \
       \
       "resin_load_env_file=" \
               "echo Loading ${resin_env_file} from ${resin_dev_type} device ${resin_dev_index} partition ${resin_boot_part};" \
               "fatload ${resin_dev_type} ${resin_dev_index}:${resin_boot_part} ${resin_kernel_load_addr} ${resin_env_file};\0" \
       \
       "resin_import_env_file=" \
               "echo Import ${resin_env_file} in environment;" \
               "env import -t ${resin_kernel_load_addr} ${filesize}\0" \
       \
       "resin_flasher_detect=" \
               "fatload ${resin_scan_dev_type} ${resin_scan_dev_index}:${resin_boot_part} ${resin_kernel_load_addr} ${resin_flasher_flag_file};\0" \
       \
       "resin_image_detect=" \
               "fatload ${resin_scan_dev_type} ${resin_scan_dev_index}:${resin_boot_part} ${resin_kernel_load_addr} ${resin_image_flag_file};\0" \
       \
       "resin_scan_devs=" \
               "echo Scanning MMC and USB devices ${resin_uboot_devices}; " \
               "for resin_scan_dev_type in mmc usb; do " \
                       "for resin_scan_dev_index in ${resin_uboot_devices}; do " \
                               "if test ${resin_flasher_skip} = 0 && run resin_flasher_detect; then " \
                                       "setenv resin_flasher_dev_index ${resin_scan_dev_index}; " \
                                       "setenv resin_dev_type ${resin_scan_dev_type}; " \
                                       "exit; " \
                               "else; " \
                                       "if test -n \"${resin_image_dev_index}\"; then ;" \
                                               "else if run resin_image_detect; then " \
                                                       "setenv resin_image_dev_index ${resin_scan_dev_index}; " \
                                                       "setenv resin_dev_type ${resin_scan_dev_type}; " \
                                               "fi; " \
                                       "fi; " \
                               "fi; " \
                       "done;" \
               "done;\0"  \
       \
       "resin_set_dev_index=" \
               "run resin_scan_devs; " \
               "if test -n ${resin_flasher_dev_index}; then " \
                       "echo Found resin flasher on ${resin_dev_type} ${resin_flasher_dev_index}; "\
                       "setenv resin_dev_index ${resin_flasher_dev_index}; "\
               "else; "\
                       "if test -n \"${resin_image_dev_index}\"; then " \
                               "echo Found resin image on ${resin_dev_type} ${resin_image_dev_index}; "\
                               "setenv resin_dev_index ${resin_image_dev_index}; "\
                       "else; " \
                               "echo ERROR: Could not find a resin image of any sort.; " \
                       "fi; " \
               "fi;\0" \
       \
       "resin_inject_env_file=" \
               "if run resin_load_env_file; then " \
                       "run resin_import_env_file;" \
               "fi;\0" \
       \
       "resin_set_kernel_root=" \
               "run resin_set_dev_index;" \
               "run resin_inject_env_file;" \
               "run resin_find_root_part_uuid;" \
               "setenv resin_kernel_root root=PARTUUID=${resin_root_part_uuid}\0"

#endif /* HEADER_ENV_RESIN_H */

