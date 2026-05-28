#
# crate-fetch class
#
# Registers 'crate' method for Bitbake fetch2.
#
# Adds support for following format in recipe SRC_URI:
# crate://<packagename>/<version>
#
def import_crate(d):
    import sys
    import os
    import bb.utils

    # 1. Search all layers in BBPATH for the 'lib/crate.py' file
    # This is the most robust way to find files within layers
    crate_file = bb.utils.which(d.getVar('BBPATH'), 'lib/crate.py')

    if not crate_file:
        # If not found, try a fallback: search for just 'crate.py' in case lib is implicit
        crate_file = bb.utils.which(d.getVar('BBPATH'), 'crate.py')

    if crate_file:
        libdir = os.path.dirname(crate_file)
        if libdir not in sys.path:
            sys.path.insert(0, libdir)
    else:
        # If we still can't find it, we'll print an error with the BBPATH for debugging
        bb.fatal("Crate Fetcher: Could not find 'lib/crate.py' in BBPATH. "
                 "Check if meta-balena-rust is in bblayers.conf.")

    # 2. Perform the import
    try:
        import crate
        if hasattr(crate, 'Crate'):
            # Only append if not already present
            if not any(isinstance(m, crate.Crate) for m in bb.fetch2.methods):
                bb.fetch2.methods.append(crate.Crate())
        else:
            bb.fatal("Crate fetcher error: Found 'crate' module at %s but it lacks 'Crate' class." % crate.__file__)
    except ImportError:
        bb.fatal("Crate fetcher error: Could not import 'crate' despite finding it at %s" % crate_file)

python crate_import_handler() {
    import_crate(d)
}

addhandler crate_import_handler
crate_import_handler[eventmask] = "bb.event.RecipePreFinalise"

def crate_get_srcrev(d):
    import_crate(d)
    return bb.fetch2.get_srcrev(d)

# Override SRCPV to make sure it imports the fetcher first
SRCPV = "${@crate_get_srcrev(d)}"
