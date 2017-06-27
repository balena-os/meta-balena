# e.g.  FILES_COMPRESS = "/path/bin1 /path/bin2 /path/bin3"
# Define what binaries that we find in the package tree will be compressed
# This variable's definition is MANDATORY if this class is used
# NOTE: path is relative to PKGD directory
FILES_COMPRESS ?= ""

DEPENDS_append = " upx"

UPX ?= "${STAGING_BINDIR_NATIVE}/upx"
UPX_ARGS ?= "--best -q"

find_and_compress() {
    # Sanity check
    if [ -z ${FILES_COMPRESS} ]; then
        bbdebug 1 "Binary compress class imported but FILES_COMPRESS variable was found empty."
    else
        #Compress
        for bin in ${FILES_COMPRESS}; do
            exec=${PKGD}$bin
            if [ -x $exec ]; then
                ${UPX} ${UPX_ARGS} "$exec"
            else
                bbfatal "$exec: Executable not found"
            fi
        done
    fi
}

PACKAGEBUILDPKGD += "find_and_compress"
