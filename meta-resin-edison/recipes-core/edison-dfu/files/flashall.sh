#!/bin/bash


BACKUP_IFS=$IFS
IFS=$(echo -en "\n\b")

GETOPTS="$(which getopt)"
if [[ "$OSTYPE" == "darwin"* ]] ; then READLINK=greadlink; else READLINK=readlink;fi;

if [[ "$OSTYPE" == "cygwin" ]] ;
then
	TEMP_DIR="$(dirname $($READLINK -f $0))"
	ESC_BASE_DIR="$(cygpath -m ${TEMP_DIR})"
	BASE_DIR="$(cygpath -m ${TEMP_DIR})"
else
	BASE_DIR="$(dirname $($READLINK -f $0))"
	ESC_BASE_DIR=${BASE_DIR/' '/'\ '}
fi;

USB_VID=8087
USB_PID=0a99
TIMEOUT_SEC=60

DO_RECOVERY=0
# Phone Flash tools configuration files
PFT_XML_FILE="${BASE_DIR}/pft-config-edison.xml"

# Handle Ifwi file for DFU update
IFWI_DFU_FILE=${ESC_BASE_DIR}/edison_ifwi-dbg

VAR_DIR="${BASE_DIR}/u-boot-envs"
if [[ "$OSTYPE" == "cygwin" ]] ; then
	VARIANT_NAME_DEFAULT="edison-defaultrndis"
	VARIANT_NAME_BLANK="edison-blankrndis"
else
	VARIANT_NAME_DEFAULT="edison-defaultcdc"
	VARIANT_NAME_BLANK="edison-blankcdc"
fi
VARIANT_NAME=$VARIANT_NAME_BLANK

LOG_FILENAME="flash.log"
OUTPUT_LOG_CMD="2>&1 | tee -a ${LOG_FILENAME} | ( sed -n '19 q'; head -n 1; cat >/dev/null )"

function print-usage {
	cat << EOF
Usage: ${0##*/} [-h][--help][--recovery] [--keep-data]
Update all software and restore board to its initial state.
 -h,--help     display this help and exit.
 -v            verbose output
 --recovery    recover the board to DFU mode using a dedicated tool,
               available only on linux and window hosts.
 --keep-data   preserve user data when flashing.
EOF
	exit -5
}

function flash-command-try {
	eval dfu-util -v -d ${USB_VID}:${USB_PID} $@ $OUTPUT_LOG_CMD
}

function flash-dfu-ifwi {
	ifwi_hwid_found=`dfu-util -l -d ${USB_VID}:${USB_PID} | grep -c $1`
	if [ $ifwi_hwid_found -ne 0 ];
	then
		flash-command ${@:2}
	fi
}

function flash-command {
	flash-command-try $@
	if [ $? -ne 0 ] ;
	then
		echo "Flash failed on $@"
		exit -1
	fi
}

function flash-debug {
	echo "DEBUG: lsusb"
	lsusb
	echo "DEBUG: dfu-util -l"
	dfu-util -l
}

function flash-ifwi {
	if [ -x "$(which phoneflashtool)" ]; then
		flash-ifwi-pft
	elif [ -x "$(which xfstk-dldr-solo)" ]; then
		flash-ifwi-xfstk
	else
		echo "!!! You should install xfstk tools, please visit http://xfstk.sourceforge.net/"
		exit -1
	fi
}

function flash-ifwi-pft {
	eval phoneflashtool --cli -f "$PFT_XML_FILE"
	if [ $? -ne 0 ];
	then
		echo "Phoneflashtool error"
		flash-debug
		exit -1
	fi
}

function flash-ifwi-xfstk {
	XFSTK_PARAMS=" --gpflags 0x80000007 --osimage ${ESC_BASE_DIR}/u-boot-edison.img"
	XFSTK_PARAMS="${XFSTK_PARAMS} --fwdnx ${ESC_BASE_DIR}/edison_dnx_fwr.bin"
	XFSTK_PARAMS="${XFSTK_PARAMS} --fwimage ${ESC_BASE_DIR}/edison_ifwi-dbg-00.bin"
	XFSTK_PARAMS="${XFSTK_PARAMS} --osdnx ${ESC_BASE_DIR}/edison_dnx_osr.bin"

	eval xfstk-dldr-solo ${XFSTK_PARAMS}
	if [ $? -ne 0 ];
	then
		echo "Xfstk tool error"
		flash-debug
		exit -1
	fi
}

function dfu-wait {
	echo "Now waiting for dfu device ${USB_VID}:${USB_PID}"
	if [ -z "$@" ]; then
		echo "Please plug and reboot the board"
        fi
	while [ `dfu-util -l -d ${USB_VID}:${USB_PID} | grep Found | grep -c ${USB_VID}` -eq 0 ] \
		&& [ $TIMEOUT_SEC -gt 0 ] && [ $(( TIMEOUT_SEC-- )) ];
	do
		sleep 1
	done

	if [ $TIMEOUT_SEC -eq 0 ];
	then
		echo "Timed out while waiting for dfu device ${USB_VID}:${USB_PID}"
		flash-debug
		if [ -z "$@" ]; then
			echo "Did you plug and reboot your board?"
			echo "If yes, please try a recovery by calling this script with the --recovery option"
                fi
		exit -2
	fi
}

# Execute old getopt to have long options support
ARGS=$($GETOPTS -o hv -l "keep-data,recovery,help" -n "${0##*/}" -- "$@");
#Bad arguments
if [ $? -ne 0 ]; then print-usage ; fi;
eval set -- "$ARGS";

while true; do
	case "$1" in
		-h|--help) shift; print-usage;;
		-v) shift; OUTPUT_LOG_CMD=" 2>&1 | tee -a ${LOG_FILENAME}";;
		--recovery) shift; DO_RECOVERY=1;;
		--keep-data) shift; VARIANT_NAME=$VARIANT_NAME_DEFAULT;;
		--) shift; break;;
	esac
done

echo "** Flashing Edison Board $(date) **" >> ${LOG_FILENAME}


if [ ${DO_RECOVERY} -eq 1 ];
then
	if [[ "$OSTYPE" == "darwin"* ]] ; then
		echo "Recovery mode is only available on windows and linux";
		exit -3
	fi

	echo "Starting Recovery mode"
	echo "Please plug and reboot the board"
	if [ ! -f "${PFT_XML_FILE}" ];
	then
		echo "${PFT_XML_FILE} does not exist"
		exit -3
	fi
	echo "Flashing IFWI"
	flash-ifwi
	echo "Recovery Success..."
	echo "You can now try a regular flash"

else
	echo "Using U-Boot target: ${VARIANT_NAME}"
	VARIANT_FILE="${VAR_DIR}/${VARIANT_NAME}.bin"
	if [ ! -f "${VARIANT_FILE}" ]; then
		echo "U-boot target ${VARIANT_NAME}: ${VARIANT_FILE} not found aborting"
		exit -5
	fi
	VARIANT_FILE=${VARIANT_FILE/' '/'\ '}

	dfu-wait

	echo "Flashing IFWI"

	flash-dfu-ifwi ifwi00 --alt ifwi00 -D "${IFWI_DFU_FILE}-00-dfu.bin"
	flash-dfu-ifwi ifwib00 --alt ifwib00 -D "${IFWI_DFU_FILE}-00-dfu.bin"

	flash-dfu-ifwi ifwi01 --alt ifwi01 -D "${IFWI_DFU_FILE}-01-dfu.bin"
	flash-dfu-ifwi ifwib01 --alt ifwib01 -D "${IFWI_DFU_FILE}-01-dfu.bin"

	flash-dfu-ifwi ifwi02 --alt ifwi02 -D "${IFWI_DFU_FILE}-02-dfu.bin"
	flash-dfu-ifwi ifwib02 --alt ifwib02 -D "${IFWI_DFU_FILE}-02-dfu.bin"

	flash-dfu-ifwi ifwi03 --alt ifwi03 -D "${IFWI_DFU_FILE}-03-dfu.bin"
	flash-dfu-ifwi ifwib03 --alt ifwib03 -D "${IFWI_DFU_FILE}-03-dfu.bin"

	flash-dfu-ifwi ifwi04 --alt ifwi04 -D "${IFWI_DFU_FILE}-04-dfu.bin"
	flash-dfu-ifwi ifwib04 --alt ifwib04 -D "${IFWI_DFU_FILE}-04-dfu.bin"

	flash-dfu-ifwi ifwi05 --alt ifwi05 -D "${IFWI_DFU_FILE}-05-dfu.bin"
	flash-dfu-ifwi ifwib05 --alt ifwib05 -D "${IFWI_DFU_FILE}-05-dfu.bin"

	flash-dfu-ifwi ifwi06 --alt ifwi06 -D "${IFWI_DFU_FILE}-06-dfu.bin"
	flash-dfu-ifwi ifwib06 --alt ifwib06 -D "${IFWI_DFU_FILE}-06-dfu.bin"

	echo "Flashing U-Boot"
	flash-command --alt u-boot0 -D "${ESC_BASE_DIR}/u-boot-edison.bin"

	echo "Flashing U-Boot Environment"
	flash-command --alt u-boot-env0 -D "${VARIANT_FILE}"

	echo "Flashing U-Boot Environment Backup"
	flash-command --alt u-boot-env1 -D "${VARIANT_FILE}" -R
        echo "Rebooting to apply partition changes"
	dfu-wait no-prompt

	echo "Flashing boot partition (kernel)"
	flash-command --alt resin-boot -D "${ESC_BASE_DIR}/resin-image-edison.hddimg"

	echo "Flashing config partition"
 	flash-command --alt resin-conf -D "${ESC_BASE_DIR}/config.img"

	echo "Flashing data_disk, (it can take up to 5 minutes... Please be patient)"
	flash-command --alt resin-data -D "${ESC_BASE_DIR}/data_disk.img"

	echo "Flashing rootfs, (it can take up to 5 minutes... Please be patient)"
	flash-command --alt resin-root -D "${ESC_BASE_DIR}/resin-image-edison.ext3" -R

	echo "Rebooting"
	echo "U-boot & Kernel System Flash Success..."
	if [ $VARIANT_NAME == $VARIANT_NAME_BLANK ] ; then
		echo "Your board needs to reboot to complete the flashing procedure, please do not unplug it for 2 minutes."
	fi
fi

IFS=${BACKUP_IFS}
