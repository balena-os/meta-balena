IMAGE_SIGN_CMD ?= "openssl dgst -sha256 -sign ${IMAGE_PRIVATE_KEY} -out ${IMAGE_SIGNATURE} ${IMAGE_SIGNED}"
IMAGE_VERIFY_SIGNATURE_CMD ?= "openssl dgst -sha256 -verify ${IMAGE_PUBLIC_KEY} -signature ${IMAGE_SIGNATURE} ${IMAGE_SIGNED}"

do_sign_generic () {
    set -x
    if [ -z "${IMAGE_SIGNED}" ] || [ -z "${IMAGE_SIGNATURE}" ]; then
      bberror "Please provide values for both IMAGE_SIGNED and IMAGE_SIGNATURE"
    fi

		# AG TODO - fetch from balena-sign
		IMAGE_PRIVATE_KEY="${WORKDIR}/balenaos-private-key.pem"
		IMAGE_PUBLIC_KEY="${WORKDIR}/balenaos-public-key.pem"
		openssl genpkey -algorithm RSA -out ${IMAGE_PRIVATE_KEY} -pkeyopt rsa_keygen_bits:2048 > /dev/null 2>&1
		openssl rsa -pubout -in ${IMAGE_PRIVATE_KEY} -out ${IMAGE_PUBLIC_KEY} > /dev/null 2>&1

    if ${IMAGE_SIGN_CMD}; then
      if [ ! ${IMAGE_VERIFY_SIGNATURE_CMD} ]; then
        bberror "Signature verification failed"
      fi
    else
      bberror "Signing of ${IMAGE_SIGNED} failed"
    fi
}
