# Matches the module build image in os/tests/extra-firmware.
FROM alpine:20251224

RUN apk add --no-cache \
    build-base \
    bison \
    flex \
    elfutils-dev \
    openssl-dev \
    bc \
    bash \
    coreutils \
    gawk \
    linux-headers

COPY build.sh /build.sh
COPY crc_gate.c Makefile /src/

CMD ["/build.sh"]
