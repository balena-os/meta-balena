SUMMARY = "LLVM compiler framework (packaged with rust)"
LICENSE = "NCSA"

S = "${RUSTSRC}/src/llvm"

LIC_FILES_CHKSUM = "file://LICENSE.TXT;md5=4c0bc17c954e99fd547528d938832bfa"

inherit cmake pythonnative

EXTRA_OECMAKE = " \
    -DLLVM_TARGETS_TO_BUILD='X86;ARM;AArch64;PowerPC' \
    -DLLVM_ENABLE_ASSERTIONS=OFF \
    -DLLVM_BUILD_DOCS=OFF \
    -DLLVM_ENABLE_TERMINFO=OFF \
    -DLLVM_ENABLE_ZLIB=OFF \
    -DLLVM_ENABLE_FFI=OFF \
    -DLLVM_INSTALL_UTILS=ON \
    -DLLVM_BUILD_TOOLS=ON \
    -DLLVM_BUILD_EXAMPLES=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_BUILD_TESTS=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_TARGET_ARCH=${TARGET_ARCH} \
"

# The debug symbols are huge here (>2GB) so suppress them since they
# provide almost no value. If you really need them then override this
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

do_compile_prepend_class-target() {
    # Fix paths in llvm-config
    sed -i "s|sys::path::parent_path(CurrentPath))\.str()|sys::path::parent_path(sys::path::parent_path(CurrentPath))).str()|g" ${S}/tools/llvm-config/llvm-config.cpp

    # Fix the hardcoded libdir in llvm-config
    sed -i 's:/lib\>:/${baselib}:g' ${S}/tools/llvm-config/llvm-config.cpp
}

do_compile() {
    oe_runmake
}

do_install_append_class-target() {
    # Disable checks on the native tools, since these should came from the native recipe
    sed -i -e 's/\(.*APPEND.*_IMPORT_CHECK_FILES_FOR_.*{_IMPORT_PREFIX}\/bin\/.*\)/#\1/' ${D}/usr/share/llvm/cmake/LLVMExports-noconfig.cmake
}

SYSROOT_PREPROCESS_FUNCS_append_class-target = " llvm_sysroot_preprocess"
SYSROOT_PREPROCESS_FUNCS_append_class-native = " llvm_native_sysroot_preprocess"

llvm_sysroot_preprocess() {
    install -d ${SYSROOT_DESTDIR}${bindir}
    cp ${B}/NATIVE/bin/llvm-config ${SYSROOT_DESTDIR}/${bindir} || bbfatal "missing llvm-config"
    cp ${B}/NATIVE/bin/llvm-tblgen ${SYSROOT_DESTDIR}/${bindir} || bbfatal "missing llvm-tblgen"
}

llvm_native_sysroot_preprocess() {
    sysroot_stage_dir ${D}${STAGING_DIR_NATIVE}/usr/libexec ${SYSROOT_DESTDIR}${bindir}
}

PACKAGES =+ "${PN}-bugpointpasses ${PN}-llvmhello ${PN}-liblto"

# Add the extra locations to avoid the complaints about unpackaged files
FILES_${PN} += "${libdir}/libLLVM*.so"
FILES_${PN}-dev += "${datadir}/llvm"
FILES_${PN}-bugpointpasses = "${libdir}/BugpointPasses.so"
FILES_${PN}-llvmhello = "${libdir}/LLVMHello.so"
FILES_${PN}-liblto = "${libdir}/libLTO.so"

BBCLASSEXTEND = "native"
