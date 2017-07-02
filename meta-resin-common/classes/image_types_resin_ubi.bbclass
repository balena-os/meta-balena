inherit image_types

# Partition labels
RESIN_BOOT_FS_LABEL ?= "resin-boot"
RESIN_BOOT_DIR ?= "${DEPLOY_DIR_IMAGE}/boot"
RESIN_CONF_DIR ?= "${DEPLOY_DIR_IMAGE}/conf"

multiubivol_mkfs () {
	         local mkubifs_args="$1"
           local additional_mkubifs_args="$2"
           local additional_ubinize_args="$3"
           local name="$4"
           if [ -z "$5" ]; then
		               local vname=""
	         else
		               local vname="_$5"
	        fi

           echo \[${name}\] >> ubinize${vname}.cfg
	         echo ${additional_ubinize_args} >> ubinize${vname}.cfg
	         mkfs.ubifs ${additional_mkubifs_args} ${mkubifs_args}
}

multiubivol_ubinize() {
  if [ -z "$1" ]; then
		local vname=""
	else
		local vname="_$1"
	fi
  ubinize -o ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}${vname}.rootfs.ubi ${UBINIZE_ARGS} ubinize${vname}.cfg

	# Cleanup cfg file
	mv ubinize${vname}.cfg ${DEPLOY_DIR_IMAGE}/

	# Create own symlinks for 'named' volumes
	if [ -n "$vname" ]; then
		cd ${DEPLOY_DIR_IMAGE}
		if [ -e ${IMAGE_NAME}${vname}.rootfs.ubifs ]; then
			ln -sf ${IMAGE_NAME}${vname}.rootfs.ubifs \
			${IMAGE_LINK_NAME}${vname}.ubifs
		fi
		if [ -e ${IMAGE_NAME}${vname}.rootfs.ubi ]; then
			ln -sf ${IMAGE_NAME}${vname}.rootfs.ubi \
			${IMAGE_LINK_NAME}${vname}.ubi
		fi
		cd -
	fi
}

IMAGE_CMD_multiubivol () {

  echo "Checking for Existing DIRs"
  if [ -d "$RESIN_BOOT_DIR/" ]
  then
    rm -rf "${RESIN_BOOT_DIR}/"
  fi

  if [ -d "$RESIN_CONF_DIR/" ]; then
    rm -rf "${RESIN_CONF_DIR}/"
  fi

  if [ -d "$DEPLOY_DIR_IMAGE/images/" ]; then
    rm -rf "${DEPLOY_DIR_IMAGE}/images/"
  fi


  echo "Create Resin conf DIR"
  mkdir -p ${RESIN_CONF_DIR}
  touch ${RESIN_CONF_DIR}/README_-_DO_NOT_DELETE_FILES_IN_THIS_DIRECTORY.txt

	echo "Copying files in RESIN_BOOT_PARTITION_FILE"
  mkdir ${RESIN_BOOT_DIR}
    echo -n '' > ${WORKDIR}/${RESIN_BOOT_FS_LABEL}.${FINGERPRINT_EXT}
    for RESIN_BOOT_PARTITION_FILE in ${RESIN_BOOT_PARTITION_FILES}; do

        echo "Handling $RESIN_BOOT_PARTITION_FILE ."

        # Check for item format
        case $RESIN_BOOT_PARTITION_FILE in
            *:*) ;;
            *) bbfatal "Some items in RESIN_BOOT_PARTITION_FILES ($RESIN_BOOT_PARTITION_FILE) are not in the 'src:dst' format."
        esac

        # Compute src and dst
        src="$(echo ${RESIN_BOOT_PARTITION_FILE} | awk -F: '{print $1}')"
        dst="$(echo ${RESIN_BOOT_PARTITION_FILE} | awk -F: '{print $2}')"
        if [ -z "${dst}" ]; then
            dst="/${src}" # dst was omitted
        fi
        src="${DEPLOY_DIR_IMAGE}/$src" # src is relative to deploy dir

        # Check that dst is an absolute path and assess if it should be a directory
        case $dst in
            /*)
                # Check if dst is a directory. Directory path ends with '/'.
                case $dst in
                    */) dst_is_dir=true ;;
                     *) dst_is_dir=false ;;
                esac
                ;;
             *) bbfatal "$dst in RESIN_BOOT_PARTITION_FILES is not an absolute path."
        esac

        # Check src type and existence
        if [ -d "$src" ]; then
            if ! $dst_is_dir; then
                bbfatal "You can't copy a directory to a file. You requested to copy $src in $dst."
            fi
            sources="$(find $src -maxdepth 1 -type f)"
        elif [ -f "$src" ]; then
            sources="$src"
        else
            bbfatal "$src is an invalid path referenced in RESIN_BOOT_PARTITION_FILES."
        fi

        # Normalize paths
        dst=$(realpath -ms $dst)
        if $dst_is_dir && [ ! "$dst" = "/" ]; then
            dst="$dst/" # realpath removes last '/' which we need to instruct mcopy that destination is a directory
        fi
        src=$(realpath -m $src)

        for src in $sources; do
            echo "Copying $src -> $dst ..."
            # Create the directories parent directories in dst
            directory="${RESIN_BOOT_DIR}"
            for path_segment in $(echo ${dst} | sed 's|/|\n|g' | head -n -1); do
                if [ -z "$path_segment" ]; then
                    continue
                fi
                directory=$directory/$path_segment
                mkdir $directory || true
            done
            cp -r ${src} ${RESIN_BOOT_DIR}/${dst}
            if $dst_is_dir; then
                md5sum ${src} | awk -v awkdst="$dst$(basename $src)" '{ $2=awkdst; print }' >> ${WORKDIR}/${RESIN_BOOT_FS_LABEL}.${FINGERPRINT_EXT}
            else
                md5sum ${src} | awk -v awkdst="$dst" '{ $2=awkdst; print }' >> ${WORKDIR}/${RESIN_BOOT_FS_LABEL}.${FINGERPRINT_EXT}
            fi
        done
    done
    # Add stamp file
    echo "${IMAGE_NAME}-${IMAGEDATESTAMP}" > ${WORKDIR}/image-version-info
    cp ${WORKDIR}/image-version-info ${RESIN_BOOT_DIR}
    md5sum ${WORKDIR}/image-version-info | awk -v filepath="/image-version-info" '{ $2=filepath; print }' >> ${WORKDIR}/${RESIN_BOOT_FS_LABEL}.${FINGERPRINT_EXT}
    # Finally add the fingerprint to boot
    cp ${WORKDIR}/${RESIN_BOOT_FS_LABEL}.${FINGERPRINT_EXT} ${RESIN_BOOT_DIR}

    init_config_json ${WORKDIR}

    cp ${WORKDIR}/config.json ${RESIN_BOOT_DIR}/config.json.init

	      # Split MKUBIFS_ARGS_<name> and UBINIZE_ARGS_<name>
	      for name in ${UBIMULTIVOL_BUILD}; do
	      	      eval local mkubifs_args=\"\$MKUBIFS_ARGS_${name}\"
                eval local additional_ubinize_args=\"\$ADDITIONAL_UBINIZE_ARGS_${name}\"
                eval local additional_mkubifs_args=\"\$ADDITIONAL_MKUBIFS_ARGS_${name}\"

	              multiubivol_mkfs "${mkubifs_args}" "${additional_mkubifs_args}" "${additional_ubinize_args}" "${name}" "${UBI_VOLNAME}"
	done
        multiubivol_ubinize ${UBI_VOLNAME}
}

IMAGE_DEPENDS_multiubivol = "mtd-utils-native"

# This variable is available to request which values are suitable for IMAGE_FSTYPES
IMAGE_TYPES = " \
    multiubivol \
