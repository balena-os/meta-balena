#!/usr/bin/env bash
# Shared harness for unit tests of shell code.
# Bash, because bats runs tests in bash. The code under test runs in sh.

BATS_LIB_PATH="${BATS_TEST_DIRNAME}/node_modules:${BATS_LIB_PATH}"

LAYER_ROOT="${BATS_TEST_DIRNAME}/../.."

# The shell a file names on its first line. The os-helpers fragments name
# none and run under sh on device.
shell_of() {
    case "$(head -n 1 "$1")" in
    '#!'*bash*) echo bash ;;
    *) echo sh ;;
    esac
}

# Each function of the file gets a bash wrapper that runs it in a fresh
# shell of the kind the file names, with errexit as the callers on device
# have. The compose sut puts the busybox sh the layer builds first on PATH.
load_shell_file() {
    local file="${LAYER_ROOT}/$1" shell fn
    shell="$(shell_of "${file}")"
    while read -r fn; do
        eval "${fn}() { ${shell} -ec '. \"\$0\"; \"\$@\"' '${file}' ${fn} \"\$@\"; }"
    done < <(sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\)().*/\1/p' "${file}")
}

load_os_helper() {
    load_shell_file "meta-balena-common/recipes-support/os-helpers/os-helpers/os-helpers-$1"
}

# Lints under the shell the file names, since sh on the host may be bash.
shellcheck_file() {
    local file="${LAYER_ROOT}/$1"
    shellcheck -s "$(shell_of "${file}")" "${file}"
}

# Fail, not skip: the tests need the real tool.
require_tool() {
    command -v "$1" >/dev/null 2>&1 || fail "no $1 on PATH: $2"
}

# A PATH that holds only these tools. Prefix a call with it:
#   PATH="$(path_with sh sed)" run some_function
path_with() {
    local bin tool
    bin="$(mktemp -d "${BATS_TEST_TMPDIR}/path-with.XXXXXX")"
    for tool in "$@"; do
        ln -sf "$(command -v "${tool}")" "${bin}/${tool##*/}"
    done
    echo "${bin}"
}
