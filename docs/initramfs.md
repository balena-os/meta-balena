# `balenaOS` initramfs

A `balenaOS` kernel embeds an initramfs image that runs from memory. This image
can be used in the following ways:

* Standard boot (non-flasher images):
  *  Assigns default UUIDs to the disks so they can be uniquely recognized
  *  Performs a filesystem check on all system partitions
  *  Expands the data partition if required
  *  Mounts the read-only hostapp
  *  Pivots root into it
