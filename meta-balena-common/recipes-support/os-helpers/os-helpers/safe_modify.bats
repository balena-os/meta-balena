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

@test "Golden path: safe_modify /path/to/file /path/to/dir/newfile" {
	dfname="tfile"
	dfpath="${tmpdir}/${dfname}"
	sfpath="${tmpfile}"
	md5=$(cat "${sfpath}" | md5sum | cut -d ' ' -f1)
	run safe_modify "${sfpath}" "${dfpath}"
  	assert_success
	newmd5=$(cat "${dfpath}" | md5sum | cut -d ' ' -f1)
	assert_equal ${md5} ${newmd5}
	refute [ -e ${tmpdir}/${dfname}.${md5}.md5sum ]
}

@test "No target directory: safe_modify /path/to/file /does/not/exist/dir/file" {
	dfname="tfile"
	dfpath="/does/not/exist/${dfname}"
	sfpath="${tmpfile}"
	md5=$(cat "${sfpath}" | md5sum | cut -d ' ' -f1)
	run safe_modify "${sfpath}" "${dfpath}"
	assert_failure
	refute [ -e ${tmpdir}/${dfname}.${md5}.md5sum ]
}


@test "Source does not exist: safe_modify /does/not/exist /path/to/new/file" {
	dfname="tfile"
	dfpath="${tmpdir}/${dfname}"
	sfpath="/does/not/exist"
	run safe_modify "${sfpath}" "${dfpath}"
	assert_failure
}

@test "Non atomic modify: testmode on, file rename ommitted" {
	export testmode=1
	dfname="tfile"
	dfpath="${tmpdir}/${dfname}"
	sfpath="${tmpfile}"
	md5=$(cat "${sfpath}" | md5sum | cut -d ' ' -f1)
	run safe_modify "${sfpath}" "${dfpath}"
	assert_success
	newmd5=$(cat "${dfpath}" | md5sum | cut -d ' ' -f1)
	assert [ ${md5} != ${newmd5} ]
	assert [ -e ${tmpdir}/${dfname}.${md5}.md5sum ]
}

@test "Integrity check: testmode on" {
	export testmode=1
	dfname="tfile"
	dfpath="${tmpdir}/${dfname}"
	sfpath="${tmpfile}"
	md5=$(cat "${sfpath}" | md5sum | cut -d ' ' -f1)
	run safe_modify "${sfpath}" "${dfpath}"
	assert_success
	assert [ -e ${tmpdir}/${dfname}.${md5}.md5sum ]
	export testmode=0
	run integrity_check "${dfpath}"
	assert_success
	newmd5=$(cat "${dfpath}" | md5sum | cut -d ' ' -f1)
	assert [ ${md5} = ${newmd5} ]
	refute [ -e ${tmpdir}/${dfname}.${md5}.md5sum ]
}

@test "Integrity check: no backup file" {
	export testmode=1
	dfname="tfile"
	dfpath="${tmpdir}/${dfname}"
	sfpath="${tmpfile}"
	run safe_modify "${sfpath}" "${dfpath}"
	assert_success
	md5=$(cat "${sfpath}" | md5sum | cut -d ' ' -f1)
	assert [ -e ${tmpdir}/${dfname}.${md5}.md5sum ]
	rm "${tmpdir}/${dfname}.${md5}.md5sum"
	run integrity_check "${dfpath}"
	assert_success
	refute [ -e ${tmpdir}/${dfname}.${md5}.md5sum ]
}

@test "Integrity check: no checksumed backup file" {
	export testmode=1
	dfname="tfile"
	dfpath="${tmpdir}/${dfname}"
	sfpath="${tmpfile}"
	run safe_modify "${sfpath}" "${dfpath}"
	assert_success
	md5=$(cat "${sfpath}" | md5sum | cut -d ' ' -f1)
	assert [ -e ${tmpdir}/${dfname}.${md5}.md5sum ]
	mv "${tmpdir}/${dfname}.${md5}.md5sum" "${tmpdir}/${dfname}.md5sum"
	set -x
	run integrity_check "${dfpath}"
	set +x
	assert_success
	refute [ -e ${tmpdir}/${dfname}.${md5}.md5sum ]
	refute [ -e ${tmpdir}/${dfname}.md5sum ]
}
