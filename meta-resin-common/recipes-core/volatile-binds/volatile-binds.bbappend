# we change LIC_FILES_CHKSUM to point to COPYING.MIT from ${S} directly
LIC_FILES_CHKSUM = "file://COPYING.MIT;md5=5750f3aa4ea2b00c2bf21b2b2a7b714d"
# we define ${S} to supress build warning complaining about S not being defined
S = "${WORKDIR}"
