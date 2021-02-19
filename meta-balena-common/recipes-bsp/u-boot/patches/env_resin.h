#ifndef HEADER_ENV_BALENA_H
#define HEADER_ENV_BALENA_H

/*
 * Assumes defined:
 *     resin_kernel_load_addr - kernel load address as we use the same
 *                              to load the env file
 *     resin_root_part        - existing in the env file to import (optional)
 *     resin_flasher_skip     - if set to 1 by integration layer, skips flasher detection (optional)
 * Defines:
 *     resin_set_kernel_root  - needs to be integrated with board
 *                              specific configuration
 *     set_os_cmdline         - Sets cmdline parameters as required by the OS
 *                              in os_cmdline env variable.
 *                              Needs to be integrated with board specific
 *                              configuration so that os_cmdline is part of the
 *                              final cmdline/bootargs passed to the kernel.
 *                              This needs to run after resin_set_kernel_root
 *                              as it can use the device scan which is
 *                              performed in resin_set_kernel_root. Otherwise
 *                              an additional scan is needed.
 *     resin_kernel_root      - the root kernel argument
 *     resin_dev_type         - device type from where we boot (e.g. mmc, usb etc.)
 *     resin_dev_index        - device index to be used at boot
 * Other notes:
 *     os_bc_wr_sz            - The exact size of 'bootcount=X' to fatwrite
 *
 */

#include <config_resin.h>

#define BALENA_ENV \
       "resin_env_file=" __stringify(BALENA_ENV_FILE) "\0" \
       "balena_extra_env_file=" __stringify(BALENA_EXTRA_ENV_FILE) "\0" \
       "os_bc_file=" __stringify(OS_BOOTCOUNT_FILE) "\0" \
       "os_bc_skip=" __stringify(OS_BOOTCOUNT_SKIP) "\0" \
       "os_bc_inced=0 \0" \
       "os_bc_lim=" __stringify(OS_BOOTCOUNT_LIMIT) "\0" \
       "os_bc_wr_sz=0xd \0" \
       "upgrade_available=0 \0" \
       "resin_flasher_flag_file=" __stringify(BALENA_FLASHER_FLAG_FILE) "\0" \
       "resin_image_flag_file=" __stringify(BALENA_IMAGE_FLAG_FILE) "\0" \
       "resin_uboot_devices=" __stringify(BALENA_UBOOT_DEVICES) "\0" \
       "resin_uboot_device_types=" __stringify(BALENA_UBOOT_DEVICE_TYPES) "\0" \
       "resin_boot_part=" __stringify(BALENA_BOOT_PART) "\0" \
       "resin_root_part=" __stringify(BALENA_DEFAULT_ROOT_PART) "\0" \
       "base_os_cmdline=" __stringify(BASE_OS_CMDLINE) "\0" \
       "resin_flasher_skip=0 \0" \
       \
       "resin_find_root_part_uuid=" \
               "fsuuid ${resin_dev_type} ${resin_dev_index}:${resin_root_part} resin_root_part_uuid\0" \
       \
       "resin_load_env_file=" \
               "echo Loading ${resin_env_file} from ${resin_dev_type} device ${resin_dev_index} partition ${resin_boot_part};" \
               "fatload ${resin_dev_type} ${resin_dev_index}:${resin_boot_part} ${resin_kernel_load_addr} ${resin_env_file};\0" \
       "balena_load_extra_env_file=" \
               "echo Loading ${balena_extra_env_file} from ${resin_dev_type} device ${resin_dev_index} partition ${resin_boot_part};" \
               "fatload ${resin_dev_type} ${resin_dev_index}:${resin_boot_part} ${resin_kernel_load_addr} ${balena_extra_env_file};\0" \
       "os_load_bootcount_file=" \
               "echo Loading ${os_bc_file} from ${resin_dev_type} device ${resin_dev_index} partition ${resin_boot_part};" \
               "fatload ${resin_dev_type} ${resin_dev_index}:${resin_boot_part} ${resin_kernel_load_addr} ${os_bc_file};\0" \
       \
       "resin_import_env_file=" \
               "echo Import ${resin_env_file} in environment;" \
               "env import -t ${resin_kernel_load_addr} ${filesize}\0" \
       \
       "balena_import_extra_env_file=" \
               "echo Import ${balena_extra_env_file} in environment;" \
               "env import -t ${resin_kernel_load_addr} ${filesize}\0" \
       \
       "os_import_bootcount_file=" \
               "echo Import ${os_bc_file} in environment;" \
               "env import -t ${resin_kernel_load_addr} ${filesize}\0" \
       \
       "os_inc_bc_save=" \
              "if test ${os_bc_skip} = 0 && test ${os_bc_inced} = 0 && test ${upgrade_available} = 1; then " \
                     "setexpr bootcount ${bootcount} + 1;" \
                     "env set os_bc_inced 1;" \
                     "echo bootcount=${bootcount} now;" \
                     "env export -t ${resin_kernel_load_addr} bootcount;" \
                     "if fatwrite ${resin_dev_type} ${resin_dev_index}:${resin_boot_part} ${resin_kernel_load_addr} ${os_bc_file} ${os_bc_wr_sz}; then; else; echo FATWRITE FAILED ; fi;" \
                     "echo bootcount=${bootcount} written to ${resin_dev_type} ${resin_dev_index}:${resin_boot_part} ${os_bc_file};" \
              "fi;\0" \
       \
       "resin_flasher_detect=" \
               "if test \"${resin_scan_dev_type}\" = usb ; then " \
	               "usb start ; " \
               "fi; " \
               "fatload ${resin_scan_dev_type} ${resin_scan_dev_index}:${resin_boot_part} ${resin_kernel_load_addr} ${resin_flasher_flag_file};\0" \
       \
       "resin_image_detect=" \
               "if test \"${resin_scan_dev_type}\" = usb ; then " \
                       "usb start ; " \
               "fi; " \
               "fatload ${resin_scan_dev_type} ${resin_scan_dev_index}:${resin_boot_part} ${resin_kernel_load_addr} ${resin_image_flag_file};\0" \
       \
       "resin_scan_devs=" \
               "echo Scanning ${resin_uboot_device_types} devices ${resin_uboot_devices}; " \
               "for resin_scan_dev_type in ${resin_uboot_device_types}; do " \
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
                       "setenv bootparam_flasher flasher; "\
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
               "fi;" \
               "if run balena_load_extra_env_file; then " \
                       "run balena_import_extra_env_file;" \
               "fi;" \
               "if run os_load_bootcount_file; then " \
                       "run os_import_bootcount_file;" \
               "else; " \
                       "echo No bootcount.env file. Setting bootcount=0 in environment;" \
                       "env set bootcount 0;" \
               "fi;\0" \
       \
       "resin_check_altroot=" \
              "setexpr resin_roota ${resin_boot_part} + 1; " \
              "setexpr resin_rootb ${resin_boot_part} + 2; " \
              "run os_inc_bc_save;" \
              "if test -n ${os_bc_lim}; then " \
                      "if test ${bootcount} -gt ${os_bc_lim}; then " \
                               "echo WARNING! BOOTLIMIT EXCEEDED. SWITCHING TO PREVIOUS ROOT;" \
                               "echo WARNING! was: resin_root_part=${resin_root_part};" \
                               "if test ${resin_root_part} = ${resin_roota}; then "\
                                       "env set resin_root_part ${resin_rootb}; " \
                               "else; "\
                                       "env set resin_root_part ${resin_roota}; " \
                               "fi;" \
                               "echo WARNING! now: resin_root_part=${resin_root_part};" \
                      "fi;" \
              "fi;\0" \
       \
       "set_os_cmdline=" \
               "setenv os_cmdline ${base_os_cmdline} ${bootparam_flasher} ${extra_os_cmdline};\0" \
       "resin_set_kernel_root=" \
               "run resin_set_dev_index;" \
               "run resin_inject_env_file;" \
               "run resin_check_altroot;" \
               "run resin_find_root_part_uuid;" \
               "setenv resin_kernel_root root=UUID=${resin_root_part_uuid}\0"

#endif /* HEADER_ENV_BALENA_H */

