# Rollback framework documentation

balenaCloud and balenaOS support [host OS Updates](https://www.balena.io/docs/reference/OS/updates/self-service/)(HUP). Rollbacks is a framework designed to roll back the OS update in case something goes wrong.

There are two rollback mechanisms in the OS, covering different update failure modes: one based on health checks [rollback-health](rollback-health), and another recognizing if the new system is unbootable for some reason [rollback-altboot](rollback-altboot). Their detailed operations are explained below.

## rollback-health
The new OS gets to userspace but something is unhealthy. Userspace is functional and we can use systemd services and bash scripts in this case.
- This state is checked by a systemd service: `rollback-health.service`.
- During a HUP, a flag file `rollback-health-breadcrumb` is left in the [state partition](https://www.balena.io/docs/reference/OS/overview/2.x/#image-partition-layout) to enable the `rollback-health` systemd service on next boot.
- `rollback-health.service` runs `rollback-health` which runs `rollback-tests`. Two things are checked to establish if balenaOS is healthy or not.
 - balenaEngine not working. The balenaEngine healthcheck is run.
 - VPN is not connecting but it used to in the previous OS.
- These tests are run once every minute for 15 minutes which is the default value of the `ROLLBACK_HEALTH_TIMEOUT` variable.
- If the OS is considered healthy, `rollback-health` clears the flag files left in the state partition. This service won't run again.
- If a rollback due to healthcheck fail is triggered, the previous OS boot hooks are run to restore previous boot files, `resin_root_part` is updated in `resinOS_uEnv.txt` in the boot parititon to point to the previous OS partition, a flag file `rollback-health-triggered` is left in the state partition, and a reboot is triggered.

## rollback-altboot
The new OS is unbootable and does not get to Linux userspace. (A kernel panic, something crashes before the OS reaches userspace and is able to run systemd). This requires the bootloader and userspace to work together. The bootloader needs to count the number of boots and userspace needs to reset the bootcount if the OS is functional.
- During a HUP, the variable `upgrade_available` is set in `resinOS_uEnv.txt` in the boot partition.
- `resinOS_uEnv.txt` is read by the bootloader and bootcount is incremented if `upgrade_available=1`
- Bootcount is saved in the boot partition. `grubenv` for grub and `bootcount.env` for u-boot.
- During a boot, the bootloader checks the value of the `bootcount` variable. If it is higher than 1, this means nothing in the OS cleared the bootcount. It is assumed that the new OS failed to reach userspace and the bootloader is supposed to boot the previous rootfs. i.e. If `resin_root_part=3` in `resinOS_uEnv.txt`, the bootloader will try to boot assuming `resin_root_part=2`
- The bootloader has done its job and booted the previous OS. However, the bootfiles (e.g dt overlay files) in the boot partition are still of the new broken rootfs as we don't have multiple copies of them in the boot partition.
- We need to copy the previous boot files into the boot partition. These files are available in the root partition in the `resin-boot` folder.
- During a HUP, a flag file `rollback-altboot-breadcrumb` is left in the state partition.
- `rollback-altboot.service` is the systemd service that runs if `rollback-altboot-breadcrumb` is present.
- `rollback-altboot.service` checks if we are running the previous root. i.e. `resin_root_part=3` in `resinOS_uEnv.txt`, but the current OS is actually mounted and running from `resin_root_part=2`.
 - If `rollback-altboot` detects that the bootloader has booted the previous rootfs.
 - `rollback-altboot` then runs boot hooks and copies over the currently running rootfs boot files from `resin-boot` into the boot partition.
 - If `rollback-altboot` fails to clear the state and reboot the board for whatever reason, `rollback-health` will attempt to clear rollback state and reboot the board after 15 minutes.
- If `rollback-altboot.service` detects that the bootloader has booted the correct rootfs, this script does nothing and lets `rollback-health.service` function. The `rollback-altboot-breadcrumb` file is cleared by the `rollback-health.service`.
