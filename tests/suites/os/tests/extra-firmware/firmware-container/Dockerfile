# This Dockerfile mimics the behavior of the linux-firmware container
# (https://github.com/balena-os/linux-firmware/blob/balena/Dockerfile) for testing
# the extra-firmware feature. Instead of using the full linux-firmware repository,
# we use a minimal test firmware file (test_extra_firmware.bin) that matches our
# test kernel module (see extra-firmware/src/hello.c). This approach is faster as it
# avoids downloading large firmware packages and ensures our custom test firmware
# is available directly in the container.
FROM alpine:3.18

RUN apk add --no-cache rsync

COPY test_extra_firmware.bin /lib/firmware/test_extra_firmware.bin

CMD ["/bin/sh", "-c", "rsync -av --delete /lib/firmware/ /extra-firmware/ && sleep infinity"]
