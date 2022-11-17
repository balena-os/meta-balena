# RAID setup

## Erasing existing metadata

If your disks have been used in an array before, the metadata will need wiped before reusing them. **This will destroy the data on the disk**.

```
$ mdadm --misc --zero-superblock /dev/disk1
```

## Creating an array

```
mdadm --create \
      --level=1 \
      --metadata=1.0 \
      --raid-devices=2 \
      --homehost=any \
      /dev/md/balena \
      /dev/disk1 \
      /dev/disk2
```

Note that an MD device node will be automatically created/acquired by mdadm, and the path give under `/dev/md` will be symlinked to the device node.

The `--homehost=any` parameter is required to instruct mdadm on balenaOS that this array does not belong to another host, and it may be assembled on any host.

Substitute any other RAID level as required. Metadata 1.0 or older with mirroring is required to boot balenaOS. Newer formats place the metadata block at the beginning of the disk, which doesn't present a readable filesystem to the firmware before the array is assembled. This also applies to any RAID levels, such as striping and parity, that don't contain a mirror on each disk.

## Automatic installation

Connect the array to your target device and boot the balenaOS flasher image from an external disk, such as a thumb drive. The flasher will automatically assemble the array and write the OS image to it, assuming it's correctly labeled `balena`. Any array that uses a different label, or is unlabeled, will not be written to.

## Manual installation

Once the array is assembled, balenaOS can be written directly to the MD device node:

```
$ dd if=balenaos.img of=/dev/md/balena bs=4096
```

The array can be stopped with mdadm

```
$ mdadm --stop /dev/md/balena
```

The disks can now be connected to your device, and the array will be assembled on boot.
