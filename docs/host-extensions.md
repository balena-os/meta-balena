# Hostapp extensions support

## Overview

BalenaOS supports layering the root filesystem with content from hostapp extension containers. In essence, hostapp extensions are container images flagged with the `io.balena.image.class=overlay` label that are overlayed during the early boot process.

Hostapp extension containers are meant to extend or modify the root filesystem in a managed way, and to house content that cannot be placed on an application container.

When deciding whether to use a hostapp extension for your content, first consider whether there is any reason why it could not be added to a standard application container.

## How it works

Mobynit runs as PID 1 and discovers container overlay filesystems by reading overlay2 metadata directly, without relying on Docker packages. During boot, it:

1. Mounts the hostapp container (identified via a `current` symlink)
2. Layers OS block containers marked with `io.balena.image.class=overlay`
3. Relocates existing mounts into the new root filesystem
4. Executes `pivot_root` to switch the system root
5. Execs `/sbin/init`

The rootfs is mounted as overlayfs lowerdirs and is intrinsically read-only.

## Building a hostapp extension container

The last stage of a hostapp extension container is shown next:

    FROM scratch

    LABEL io.balena.image.class=overlay

    COPY --from=builder /hostext /

The example Dockerfile above starts with an empty container, then adds the `io.balena.image.class=overlay` label so that BalenaOS can identify it and overlay it at boot, and finally the desired content is copied from a space holder directory to the root of this container.

By default, extensions are mounted to the right of the hostapp in the overlayfs lowerdir stack, meaning they can only contribute new files — they cannot replace existing hostapp content.

## Mount ordering

Extensions can define a mount order using the `io.balena.image.override=N` label, where N is a numeric priority. Extensions with this label are mounted to the left of the hostapp in the overlayfs lowerdir stack, enabling them to replace existing hostapp files. Lower N values have higher overlayfs precedence. Equal priorities sort by container name for deterministic behavior.

    FROM scratch

    LABEL io.balena.image.class=overlay
    LABEL io.balena.image.override=10

    COPY --from=builder /hostext /

In overlayfs terminology, `lowerdir=A:B:C` means A has the highest lookup priority. The resulting lowerdir is: `lowerdir=<extensions with override sorted by N>:<hostapp>:<extensions without override>`.

Care should be taken not to shadow root filesystem content which is essential for BalenaOS to function.

## Managing hostapp extensions

Extensions are meant to be managed by the supervisor or as part of a hostOS update. Manually installing, removing or updating hostapp extensions is neither advised nor supported.

## Disabling hostapp extension overlays

An incorrect hostapp extension can leave your system in a non-working state. Balena advises against deploying custom made hostapp extensions and recommends to either use the hostapp extensions included as part of BalenaOS releases, or let the supervisor manage the installation, update and removal of production ready hostapp extensions.

The overlaying of hostapp extensions can be disabled by specifying either of the following kernel command line arguments:

* `mobynit.no_overlays`
* `emergency`

## Caveats

* The root filesystem is intrinsically read-only when hostapp extensions are layered.
* Hostapp extensions require the overlay2 storage driver.
