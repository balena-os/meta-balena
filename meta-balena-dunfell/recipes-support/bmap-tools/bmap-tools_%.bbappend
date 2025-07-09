# Needed on layers before Scarthgap (Scarthgap renamed bmap-tools to bmaptool)
PROVIDES += "bmaptool"

# Change branch to main - Nov 2024 master was renamed main upstream
SRC_URI = "git://github.com/intel/bmap-tools;branch=main;protocol=https"