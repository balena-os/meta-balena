do_install:append() {
    (
	cd ${S}

	# for v6.1+ (otherwise we are missing multiple default targets)
	cp -a --parents Kbuild $kerneldir/build 2>/dev/null || :

	if [ "${ARCH}" = "arm64" ]; then
	    # v6.1+
	    cp -a --parents arch/arm64/kernel/asm-offsets.c $kerneldir/build/
            cp -a --parents arch/arm64/tools/gen-sysreg.awk $kerneldir/build/ 2>/dev/null || :
            cp -a --parents arch/arm64/tools/sysreg $kerneldir/build/ 2>/dev/null || :
            if [ -e $kerneldir/build/arch/arm64/tools/gen-sysreg.awk ]; then
                 sed -i -e "s,#!.*awk.*,#!${USRBINPATH}/env awk," $kerneldir/build/arch/arm64/tools/gen-sysreg.awk
            fi
	fi

	if [ "${ARCH}" = "powerpc" ]; then
	    # v5.19+
	    cp -a --parents arch/powerpc/kernel/vdso/*.S $kerneldir/build 2>/dev/null || :
	    cp -a --parents arch/powerpc/kernel/vdso/*gettimeofday.* $kerneldir/build 2>/dev/null || :
	    cp -a --parents arch/powerpc/kernel/vdso/gen_vdso*_offsets.sh $kerneldir/build/ 2>/dev/null || :

	    # v6,1+
	    cp -a --parents arch/powerpc/kernel/asm-offsets.c $kerneldir/build/ 2>/dev/null || :
	fi

	# include the machine specific headers for ARM variants, if available.
	if [ "${ARCH}" = "arm" ]; then
            # v6.1+
            cp -a --parents arch/arm/kernel/asm-offsets.c $kerneldir/build/ 2>/dev/null || :
            cp -a --parents arch/arm/kernel/signal.h $kerneldir/build/ 2>/dev/null || :
            cp -a --parents arch/arm/tools/gen-sysreg.awk $kerneldir/build/ 2>/dev/null || :
	fi

	if [ "${ARCH}" = "x86" ]; then
	    # v6.1+
	    cp -a --parents arch/x86/kernel/asm-offsets* $kerneldir/build || :
	    # for capabilities.h, vmx.h
	    cp -a --parents arch/x86/kvm/vmx/*.h $kerneldir/build || :
	    # for lapic.h, hyperv.h ....
	    cp -a --parents arch/x86/kvm/*.h $kerneldir/build || :
	fi

	# moved from arch/mips to all arches for v6.1+
	cp -a --parents kernel/time/timeconst.bc $kerneldir/build 2>/dev/null || :
	cp -a --parents kernel/bounds.c $kerneldir/build 2>/dev/null || :
    )

    chown -R root:root ${D}
}

do_install:append() {
   tar -czf ${WORKDIR}/kernel_modules_headers.tar.gz -C "$kerneldir/../" .
}
