do_install_append() {
    # Remove all fonts except Sans regular used for Plymouth boot text
    find ${D}${prefix}/share/fonts/ttf/ -type f \( -iname "*.ttf" ! -iname "LiberationSans-Regular.ttf" \) | xargs rm -f
}
