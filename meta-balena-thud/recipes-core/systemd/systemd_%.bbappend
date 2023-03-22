FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"

SRC_URI_append = " \
	file://0001-core-Don-t-redirect-stdio-to-null-when-running-in-co.patch \
	file://backport-6caa14f763c11630f28d587b3caa5f0e6dc96165.patch \
	"
