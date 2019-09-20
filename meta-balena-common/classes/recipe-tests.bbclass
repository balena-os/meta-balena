runtest() {
    cmd="$1"
    ecode="$2"
    estdout="$3"
    failed=0

    bbnote "Run test ..."
    bbnote "  command: $cmd"
    bbnote "  expected exit code: $ecode"
    bbnote "  expected standard output: $estdout"

    stdout="$(eval "$cmd")" && rc=$? || rc=$? 
    if [ "$rc" -ne "$ecode" ]; then
        bbwarn "Unexpected exit code: $rc. Expected: $ecode."
        failed=1
    fi
    if [ "$stdout" != "$estdout" ]; then
        bbwarn "Unexpected output: \"$stdout\". Expected: \"$estdout\"."
        bbwarn "Failing command: $cmd"
        failed=1
    fi
    if [ "$failed" -ne 0 ]; then
        bbwarn "Test failed. Command: $cmd"
    else
        bbnote "Test passed."
    fi
}

# Boilerplate for runtests task. Append to it with your own tests
do_runtests() {
    bbnote "Running ${PN} tests..."
}
addtask runtests before do_package after do_install
