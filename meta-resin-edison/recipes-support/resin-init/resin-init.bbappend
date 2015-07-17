do_patch_append () {
    # We don't expand partitions on edison as they are already the right size
    import subprocess
    subprocess.call("sed -i 's|.*parted -s /dev/$datadev -- resizepart.*|# No expand partition needed on edison|g' ${WORKDIR}/resin-init", shell=True)
}
