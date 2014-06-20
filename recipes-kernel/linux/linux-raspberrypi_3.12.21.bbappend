FILESEXTRAPATHS_prepend := "${THISDIR}/files:"


do_configure_append(){

	kernel_configure_variable USER_NS y
	kernel_configure_variable UIDGID_STRICT_TYPE_CHECKS y
	kernel_configure_variable DEVPTS_MULTIPLE_INSTANCES y

}
