#!/usr/bin/env /bin/bats
load "recipe-sysroot-native/usr/lib/bats-support/load"
load "recipe-sysroot-native/usr/lib/bats-assert/load"

source ${BATS_TEST_DIRNAME}/os-helpers-fs

setup() {
	tmpdir=$(mktemp -d)
	tmpfile=$(mktemp --tmpdir=${tmpdir})
	echo -b "test content" > "${tmpfile}"
}

teardown() {
	rm -rf "${tmpdir}"
}

@test "Golden path: verify_cksum </path/to/file> <checksum>" {
	sfpath="${tmpfile}"
	md5=$(cat ${sfpath} | md5sum | cut -d ' ' -f1)
	run verify_cksum "${sfpath}" "${md5}"
	assert_success
}

@test "Wrong checksum: verify_cksum </path/to/file> <checksum>" {
	sfpath="${tmpfile}"
	run verify_cksum "${sfpath}" "00000000000000000000000000000000"
	assert_failure
}

@test "No checksum: verify_cksum </path/to/file>" {
	sfpath="${tmpfile}"
	run verify_cksum "${sfpath}"
	assert_failure
}

@test "No source file: verify_cksum </does/not/exist> <checksum>" {
	sfpath="/does/not/exit"
	run verify_cksum "${sfpath}" "00000000000000000000000000000000"
	assert_failure
}
