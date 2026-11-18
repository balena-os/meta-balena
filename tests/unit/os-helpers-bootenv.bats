#!/usr/bin/env bats
# Copyright 2026 Balena Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

setup() {
    load 'helpers/common'
    bats_load_library bats-support
    bats_load_library bats-assert
    load 'helpers/bootenv'
    bootenv_setup
    load_os_helper bootenv
}

@test "os-helpers-bootenv is clean under shellcheck" {
    require_tool shellcheck "install shellcheck"
    run shellcheck_file meta-balena-common/recipes-support/os-helpers/os-helpers/os-helpers-bootenv
    assert_success
}

#
# bootenv_get
#

@test "bootenv_get prints the value of a key" {
    bootenv_set "${BOOTENV}" bootcount 3
    run bootenv_get "${BOOTENV}" bootcount
    assert_success
    assert_output "3"
}

@test "bootenv_get prints nothing for a key that is not set" {
    run bootenv_get "${BOOTENV}" absent
    assert_success
    assert_output ""
}

@test "bootenv_get prints nothing for a missing file" {
    run bootenv_get "${BATS_TEST_TMPDIR}/none" bootcount
    assert_success
    assert_output ""
}

@test "bootenv_get prints nothing for an empty key" {
    bootenv_set "${BOOTENV}" bootcount 3
    run bootenv_get "${BOOTENV}" ""
    assert_success
    assert_output ""
}

@test "bootenv_get prints nothing when grub-editenv is absent" {
    bootenv_set "${BOOTENV}" bootcount 3
    PATH="$(path_without_grub_editenv)" run bootenv_get "${BOOTENV}" bootcount
    assert_success
    assert_output ""
}

@test "bootenv_get keeps a value that holds an equals sign" {
    bootenv_set "${BOOTENV}" cmdline "root=/dev/sda2 ro"
    run bootenv_get "${BOOTENV}" cmdline
    assert_success
    assert_output "root=/dev/sda2 ro"
}

@test "bootenv_get does not match a key that only shares a prefix" {
    bootenv_set "${BOOTENV}" kernel_override_abi_committed_a "$(abi 1)"
    run bootenv_get "${BOOTENV}" kernel_override_abi
    assert_success
    assert_output ""
}

#
# bootenv_is_kernel_abi
#

@test "bootenv_is_kernel_abi accepts 64 lowercase hex digits" {
    run bootenv_is_kernel_abi "$(abi 1)"
    assert_success
}

@test "bootenv_is_kernel_abi rejects uppercase hex" {
    run bootenv_is_kernel_abi "$(abi 1 | tr 'a-f' 'A-F')"
    assert_failure
}

@test "bootenv_is_kernel_abi rejects an id that is one digit short" {
    local short
    short="$(abi 1)"
    run bootenv_is_kernel_abi "${short:0:63}"
    assert_failure
}

@test "bootenv_is_kernel_abi rejects an id that is one digit long" {
    run bootenv_is_kernel_abi "$(abi 1)0"
    assert_failure
}

@test "bootenv_is_kernel_abi rejects a non hex digit" {
    local bad
    bad="$(abi 1)"
    run bootenv_is_kernel_abi "${bad:0:63}g"
    assert_failure
}

@test "bootenv_is_kernel_abi rejects an empty value" {
    run bootenv_is_kernel_abi ""
    assert_failure
}

#
# bootenv_edit
#

@test "bootenv_edit fails and writes no file when grub-editenv is absent" {
    local block="${BATS_TEST_TMPDIR}/none"
    PATH="$(path_without_grub_editenv)" run bootenv_edit "${block}" set bootcount=0
    assert_failure
    assert [ ! -e "${block}" ]
}

@test "bootenv_edit applies several assignments in one edit" {
    run bootenv_edit "${BOOTENV}" set bootcount=0 upgrade_available=0
    assert_success
    run bootenv_entries
    assert_output $'bootcount=0\nupgrade_available=0'
}

@test "bootenv_edit keeps the keys already in a valid block" {
    bootenv_set "${BOOTENV}" first 1
    run bootenv_edit "${BOOTENV}" set second=2
    assert_success
    run bootenv_entries
    assert_output $'first=1\nsecond=2'
}

@test "bootenv_edit rebuilds an invalid block and then applies the edit" {
    : > "${BOOTENV}"
    run bootenv_edit "${BOOTENV}" set kernel_override_abi=0
    assert_success
    assert_grub_block
    run bootenv_entries
    assert_output "kernel_override_abi=0"
}

@test "bootenv_edit rebuilds the block in place" {
    local before
    : > "${BOOTENV}"
    before="$(stat -c%i "${BOOTENV}")"
    run bootenv_edit "${BOOTENV}" set bootcount=0
    assert_success
    assert_equal "$(stat -c%i "${BOOTENV}")" "${before}"
}

# A directory makes list fail for another reason.
@test "bootenv_edit fails and keeps the path when grub-editenv cannot read it" {
    local block="${BATS_TEST_TMPDIR}/adir"
    mkdir -p "${block}"
    run bootenv_edit "${block}" set bootcount=0
    assert_failure
    assert [ -d "${block}" ]
    assert [ -z "$(ls -A "${block}")" ]
}

# The test holds the lock on fd 9. The writer must not inherit that fd,
# or it would keep the lock alive after the test releases it.
@test "bootenv_edit waits for a writer that already holds the lock" {
    exec 9<"${BOOTENV}"
    flock 9
    bootenv_edit "${BOOTENV}" set bootcount=0 9<&- &
    sleep 1
    assert_equal "$(bootenv_get "${BOOTENV}" bootcount)" ""

    exec 9<&-
    wait "$!"
    assert_equal "$(bootenv_get "${BOOTENV}" bootcount)" "0"
}

# Unlocked writers lost a key in 13/50 rounds.
@test "two writers under the lock keep both keys" {
    for _ in $(seq 20); do
        grub-editenv "${BOOTENV}" create
        bootenv_edit "${BOOTENV}" set first=1 &
        bootenv_edit "${BOOTENV}" set second=2 &
        wait
        run bootenv_entries
        assert_output $'first=1\nsecond=2'
    done
}

#
# bootenv_set and bootenv_unset
#

@test "bootenv_set writes a key that bootenv_unset removes" {
    bootenv_set "${BOOTENV}" bootcount 1
    assert_equal "$(bootenv_get "${BOOTENV}" bootcount)" "1"
    bootenv_unset "${BOOTENV}" bootcount
    run bootenv_entries
    refute_output --partial "bootcount="
}

@test "bootenv_unset succeeds for a key that is not there" {
    run bootenv_unset "${BOOTENV}" absent
    assert_success
}

#
# bootenv_restore_kernel_override
#

@test "bootenv_restore_kernel_override clears the override when the slot committed none" {
    bootenv_set "${BOOTENV}" kernel_override_abi "$(abi 2)"
    run bootenv_restore_kernel_override "${BOOTENV}" a
    assert_success
    run bootenv_entries
    refute_output --partial "kernel_override_abi="
}

@test "bootenv_restore_kernel_override reads the committed override of the named slot" {
    bootenv_set "${BOOTENV}" kernel_override_abi "$(abi 3)"
    bootenv_set "${BOOTENV}" kernel_override_abi_committed_a "$(abi 1)"
    bootenv_set "${BOOTENV}" kernel_override_abi_committed_b "$(abi 2)"
    run bootenv_restore_kernel_override "${BOOTENV}" b
    assert_success
    assert_equal "$(bootenv_get "${BOOTENV}" kernel_override_abi)" "$(abi 2)"
}

#
# bootenv_reject_kernel_override
#

@test "bootenv_reject_kernel_override records the rejected ABI and restores the committed one" {
    bootenv_set "${BOOTENV}" kernel_override_abi "$(abi 2)"
    bootenv_set "${BOOTENV}" kernel_override_abi_committed_a "$(abi 1)"
    run bootenv_reject_kernel_override "${BOOTENV}" a "$(abi 2)"
    assert_success
    assert_equal "$(bootenv_get "${BOOTENV}" kernel_override_abi_rejected)" "$(abi 2)"
    assert_equal "$(bootenv_get "${BOOTENV}" kernel_override_abi)" "$(abi 1)"
}

@test "bootenv_reject_kernel_override takes the active override as the booted one" {
    bootenv_set "${BOOTENV}" kernel_override_abi "$(abi 2)"
    bootenv_set "${BOOTENV}" kernel_override_abi_committed_a "$(abi 1)"
    run bootenv_reject_kernel_override "${BOOTENV}" a
    assert_success
    assert_equal "$(bootenv_get "${BOOTENV}" kernel_override_abi_rejected)" "$(abi 2)"
}

@test "bootenv_reject_kernel_override records nothing when the override is already committed" {
    bootenv_set "${BOOTENV}" kernel_override_abi "$(abi 1)"
    bootenv_set "${BOOTENV}" kernel_override_abi_committed_a "$(abi 1)"
    run bootenv_reject_kernel_override "${BOOTENV}" a
    assert_success
    assert_equal "$(bootenv_get "${BOOTENV}" kernel_override_abi_rejected)" ""
    assert_equal "$(bootenv_get "${BOOTENV}" kernel_override_abi)" "$(abi 1)"
}

@test "bootenv_reject_kernel_override records nothing when another ABI booted" {
    bootenv_set "${BOOTENV}" kernel_override_abi "$(abi 2)"
    run bootenv_reject_kernel_override "${BOOTENV}" a "$(abi 3)"
    assert_success
    assert_equal "$(bootenv_get "${BOOTENV}" kernel_override_abi_rejected)" ""
    run bootenv_entries
    refute_output --partial "kernel_override_abi="
}

@test "bootenv_reject_kernel_override still restores when no override is active" {
    bootenv_set "${BOOTENV}" kernel_override_abi_committed_a "$(abi 1)"
    run bootenv_reject_kernel_override "${BOOTENV}" a
    assert_success
    assert_equal "$(bootenv_get "${BOOTENV}" kernel_override_abi_rejected)" ""
    assert_equal "$(bootenv_get "${BOOTENV}" kernel_override_abi)" "$(abi 1)"
}
