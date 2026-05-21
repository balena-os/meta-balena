# balena-hostapp-extension.bbclass
#
# Generic image-build infrastructure for balena hostapp extensions.
#
# Kernel-override behavior is automatic and based on a single signal:
# the assembled image rootfs containing BOTH Module.symvers (under
# /lib/modules/<ver>/) AND a kernel image (under /boot/).
#
# Usage:
#   inherit balena-hostapp-extension
#   IMAGE_INSTALL = "<your extension packages>"
#
# Inheriting recipes can append more docker-import directives via:
#   HOSTAPP_EXTENSION_LABELS  - extra `--change "LABEL ..."` lines
#   HOSTAPP_EXTENSION_CHANGES - extra `--change "..."` lines (VOLUME, ENV, ...)
#
# The values of the four conventional labels can be overridden per-recipe:
#   HOSTAPP_EXTENSION_LABEL_STORE            - io.balena.image.store          (default: data)
#   HOSTAPP_EXTENSION_LABEL_CLASS            - io.balena.image.class          (default: overlay)
#   HOSTAPP_EXTENSION_LABEL_OVERRIDE         - io.balena.image.override       (default: 100)
#   HOSTAPP_EXTENSION_LABEL_REQUIRES_REBOOT  - io.balena.update.requires-reboot (default: 1)

inherit image

HOSTAPP_EXTENSION_LABELS ?= ""
HOSTAPP_EXTENSION_CHANGES ?= ""

# Conventional labels carried by every hostapp extension. Defaults reflect
# the kernel-override case; non-kernel extensions can override any of these
# (e.g. HOSTAPP_EXTENSION_LABEL_REQUIRES_REBOOT = "0" for a hot-applied one).
HOSTAPP_EXTENSION_LABEL_STORE           ?= "data"
HOSTAPP_EXTENSION_LABEL_CLASS           ?= "overlay"
HOSTAPP_EXTENSION_LABEL_OVERRIDE        ?= "100"
HOSTAPP_EXTENSION_LABEL_REQUIRES_REBOOT ?= "1"

# Always-on: the hooks self-detect kernel content at runtime and
# silently no-op for non-kernel extensions.
IMAGE_INSTALL:append = " kernel-override-hooks"

IMAGE_PREPROCESS_COMMAND:append = " install_kernel_override_symvers;"

# Install the kernel's Module.symvers under /usr/lib/modules/<ver>/ in the
# rootfs if the rootfs already contains a kernel image.
install_kernel_override_symvers() {
    [ -e "${IMAGE_ROOTFS}/boot/${KERNEL_IMAGETYPE}" ] || return 0

    KVER_DIR=$(find "${IMAGE_ROOTFS}/usr/lib/modules" "${IMAGE_ROOTFS}/lib/modules" \
        -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort -u | head -n1)
    [ -n "${KVER_DIR}" ] || \
        bbfatal "kernel image at /boot/${KERNEL_IMAGETYPE} but no /lib/modules/<ver>/ in rootfs"
    KERNEL_VER_FULL=$(basename "${KVER_DIR}")

    # If Module.symvers is already there (a -dev package laid it down), nothing to do.
    [ ! -f "${KVER_DIR}/Module.symvers" ] || return 0

    # Strip LOCALVERSION suffix (e.g. 6.12.62-v8-16k → 6.12.62) for matching the
    # .config header.
    KVER_NUM="${KERNEL_VER_FULL%%-*}"
    SYMVERS=""
    for cfg in "${DEPLOY_DIR_IMAGE}/.config" "${DEPLOY_DIR_IMAGE}"/*/.config; do
        [ -f "$cfg" ] || continue
        if head -3 "$cfg" | grep -qE "Linux/[A-Za-z0-9_]+ ${KVER_NUM} Kernel Configuration"; then
            candidate="$(dirname "$cfg")/Module.symvers"
            [ -f "${candidate}" ] || continue
            SYMVERS="${candidate}"
            break
        fi
    done
    [ -n "${SYMVERS}" ] || \
        bbfatal "no Module.symvers in ${DEPLOY_DIR_IMAGE} matches kernel ${KERNEL_VER_FULL}"

    install -m 0644 "${SYMVERS}" "${KVER_DIR}/Module.symvers"
}

do_create_docker_image() {
    TARBALL="${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.tar.gz"
    [ -e "${TARBALL}" ] || bbfatal "Rootfs tarball not found at ${TARBALL}"

    _docker_import_extension() {
        DOCKER_API_VERSION=${BALENA_API_VERSION} docker import \
            --change "LABEL io.balena.image.store=${HOSTAPP_EXTENSION_LABEL_STORE}" \
            --change "LABEL io.balena.image.class=${HOSTAPP_EXTENSION_LABEL_CLASS}" \
            --change "LABEL io.balena.image.override=${HOSTAPP_EXTENSION_LABEL_OVERRIDE}" \
            --change "LABEL io.balena.update.requires-reboot=${HOSTAPP_EXTENSION_LABEL_REQUIRES_REBOOT}" \
            --change "LABEL io.balena.image.os-version=${HOSTOS_VERSION}" \
            "$@" \
            ${HOSTAPP_EXTENSION_LABELS} \
            ${HOSTAPP_EXTENSION_CHANGES} \
            "${TARBALL}" "${IMAGE_NAME}:latest"
    }

    LISTING=$(tar -tzf "${TARBALL}")
    HAS_SYMVERS=$(echo "${LISTING}" | grep -m1 -E '^\./(usr/)?lib/modules/[^/]+/Module\.symvers$' || true)
    HAS_KERNEL_IMG=0
    echo "${LISTING}" | grep -qFx "./boot/${KERNEL_IMAGETYPE}" && HAS_KERNEL_IMG=1

    if [ -n "${HAS_SYMVERS}" ] && [ "${HAS_KERNEL_IMG}" = "1" ]; then
        KERNEL_VER_FULL=$(echo "${HAS_SYMVERS}" \
            | sed -E 's|^\./(usr/)?lib/modules/([^/]+)/Module\.symvers$|\2|')
        KERNEL_VER="${KERNEL_VER_FULL%%-*}"
        KERNEL_ABI_ID=$(tar -xzOf "${TARBALL}" "${HAS_SYMVERS}" | sha256sum | awk '{print $1}')
        [ "${#KERNEL_ABI_ID}" -eq 64 ] || bbfatal "Invalid KERNEL_ABI_ID from ${HAS_SYMVERS} in ${TARBALL}: '${KERNEL_ABI_ID}'"

        bbnote "Kernel-override extension (image=${KERNEL_IMAGETYPE}, version=${KERNEL_VER}, abi=${KERNEL_ABI_ID})"

        _docker_import_extension \
            --change "LABEL io.balena.image.kernel-version=${KERNEL_VER}" \
            --change "LABEL io.balena.image.kernel-abi-id=${KERNEL_ABI_ID}" \
            --change "VOLUME /boot"
    elif [ -z "${HAS_SYMVERS}" ] && [ "${HAS_KERNEL_IMG}" = "0" ]; then
        # Not a kernel-override extension, common labels only.
        _docker_import_extension
    elif [ -z "${HAS_SYMVERS}" ]; then
        bbfatal "kernel image at /boot/${KERNEL_IMAGETYPE} present in tarball but Module.symvers missing"
    else
        bbfatal "Module.symvers present in tarball but no kernel image at /boot/${KERNEL_IMAGETYPE}"
    fi

    DOCKER_API_VERSION=${BALENA_API_VERSION} docker save -o "${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.docker" "${IMAGE_NAME}:latest"
    DOCKER_API_VERSION=${BALENA_API_VERSION} docker rmi "${IMAGE_NAME}:latest" || true
}
addtask create_docker_image after do_image_complete before do_build
