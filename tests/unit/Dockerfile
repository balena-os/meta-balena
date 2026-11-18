# The sut for docker-compose.test.yml. The code under test runs in the
# busybox sh that the layer builds for the device, so the result does not
# depend on the host shell. The repo mounts at /src, so the final image
# holds only the tools and the bats libraries.
ARG BUSYBOX_VERSION=1.35.0

FROM alpine:3.21 AS busybox
ARG BUSYBOX_VERSION
ARG BUSYBOX_SHA256=faeeb244c35a348a334f4a59e44626ee870fb07b6884d68c10ae8bc19f83a694
RUN apk add --no-cache build-base linux-headers bzip2
WORKDIR /build
RUN wget -q "https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2" \
    && echo "${BUSYBOX_SHA256}  busybox-${BUSYBOX_VERSION}.tar.bz2" | sha256sum -c \
    && tar xjf "busybox-${BUSYBOX_VERSION}.tar.bz2" --strip-components=1
COPY meta-balena-common/recipes-core/busybox/busybox/defconfig .config
COPY meta-balena-common/recipes-core/busybox/busybox/balenaos.cfg .
# The merge busybox.inc does: the fragment wins over the defconfig.
RUN for line in $(grep '^CONFIG_' balenaos.cfg); do \
        name="${line%%=*}"; \
        sed -i "/^${name}=/d; /^# ${name} is not set/d" .config; \
        echo "${line}" >> .config; \
    done \
    && yes "" | make oldconfig >/dev/null \
    && make -j"$(nproc)" busybox

FROM node:22-alpine
RUN apk add --no-cache bash grub shellcheck
# Only sh comes from the device busybox. bats keeps the Alpine tools.
COPY --from=busybox /build/busybox /opt/busybox/busybox
RUN ln -s busybox /opt/busybox/sh
WORKDIR /deps
COPY tests/unit/package.json tests/unit/package-lock.json ./
RUN npm ci
ENV PATH="/opt/busybox:/deps/node_modules/.bin:${PATH}" \
    BATS_LIB_PATH=/deps/node_modules
WORKDIR /src/tests/unit
CMD ["npm", "test"]
