# Hostapp extensions support

## Overview

BalenaOS supports layering the root filesystem with content from hostapp extension containers. In essence, hostapp extensions are container images flagged with the `balena.io.features.host-extension` label that are overlayed during the early boot process.

Hostapp extension containers are meant to extend or modify the root filesystem in a managed way, and to house content that cannot be placed on an application container.

When deciding whether to use a hostapp extension for your content, first consider whether there is any reason why it could not be added to a standard application container.

## Building a hostapp extension container

The last stage of a hostapp extension container is shown next:

    FROM scratch

    LABEL io.balena.features.host-extension=1

    COPY --from=builder /hostext /

The example Dockerfile above starts with an empty container, then adds the `io.balena.features.host-extension` label so that BalenaOS can identify it and overlay it at boot, and finally the desired content is copied from a space holder directory to the root of this container. Care should be taken not to shadow root filesystem content which is essential for BalenaOS to function.

## Managing hostapp extensions

Extensions are meant to be managed by the supervisor or as part of a hostOS update. Manually installing, removing or updating hostapp extensions is neither advised nor supported.

To preload hostapp extensions when building the host OS images, add a space or colon separated list of public hostapp extensions application names to your __conf/local.conf__ configuration file. For example, if there is a public app called __linux-firmware__ you would add:

    HOSTEXT_IMAGES = "linux-firmware"

## Disabling hostapp extension overlays

An incorrect hostapp extension can leave your system in a non-working state. Balena advises against deploying custom made hostapp extensions and recommends to either use the hostapp extensions included as part of BalenaOS releases, or let the supervisor manage the installation, update and removal of production ready hostapp extensions.

The overlaying of hostapp extensions can be disabled by specifying a `balena.nohostext` argument to the kernel command line.

## Caveats

* Once BalenaOS has overlayed a hostapp extension the root filesystem cannot be remounted read-write.
* Hostapp extensions are only supported for overlay2 filesystems
* The numbers of extensions that can be mounted is capped by the length of the options passed to the kernel's do_mount() function which is currently the system's page size. For the typical paths in BalenaOS this is around 20 containers.
