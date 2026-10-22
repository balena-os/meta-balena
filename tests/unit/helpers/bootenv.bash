#!/usr/bin/env bash
# Fixtures for the grub-env block of os-helpers-bootenv.

GRUB_BLOCK_SIZE=1024

# Every test starts from a valid, empty block at BOOTENV.
bootenv_setup() {
    require_tool grub-editenv "install grub, or run the suite in the compose sut"
    BOOTENV="${BATS_TEST_TMPDIR}/bootenv"
    grub-editenv "${BOOTENV}" create
}

bootenv_entries() {
    grub-editenv "${BOOTENV}" list | sort
}

# Everything the helper under test needs, except grub-editenv.
path_without_grub_editenv() {
    path_with sh flock sed grep tr
}

# grub-editenv list already validates the signature.
assert_grub_block() {
    local padding
    assert [ "$(stat -c%s "${BOOTENV}")" -eq "${GRUB_BLOCK_SIZE}" ]
    padding="$(tail -n +2 "${BOOTENV}")"
    padding="${padding##*$'\n'}"
    assert [ -z "${padding//[#]/}" ]
    run grub-editenv "${BOOTENV}" list
    assert_success
}

# A valid kernel ABI: 64 lowercase hex digits.
abi() {
    printf '%064x' "$((0xabc0000 + ${1:-0}))"
}
