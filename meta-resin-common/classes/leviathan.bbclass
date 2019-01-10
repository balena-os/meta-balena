#
# Leviathan integration
#

# Configuration

LEVIATHAN_VERSION ?= "latest"
DOCKER_IMAGE ?= "telphan/test"
SUITES ?= ""

# Internal Configuration

ENVIRONMENT_VARIABLE_PREFIX = "BALENA_TESTS"

if [ ! -z ${CI} ]; then
  DOCKER_TTY = '--tty'
  DOCKER_INTERACTIVE = '--interactive'
fi

run_leviathan () {
  echo "Starting Leviathan..."

  for var in $(compgen -e | grep ${ENVIRONMENT_VARIABLE_PREFIX}); do
    ENV+="\"${var}=${!var}\" "
  done

  docker run --rm \
    --env "CI=${CI}" \
    --env "GITHUB_TOKEN=${GITHUB_TOKEN}" \
    --env ${ENV} \
    --env "BALENA_TESTS_SUITE_NAME=${1}"
    --privileged \
    ${DOCKER_TTY} \
    ${DOCKER_INTERACTIVE} \
    ${DEVICE} \
    "${DOCKER_IMAGE}:${LEVIATHAN_VERSION}"
}

run_test_suites () {
  for suite in ${SUITES}; do
    run_leviathan ${suite}
  done
}

IMAGE_POSTPROCESS_COMMAND =+ "run_test_suites"
