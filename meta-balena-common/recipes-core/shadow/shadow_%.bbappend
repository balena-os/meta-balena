# Needed to get newuidmap/newgidmap built.
PACKAGECONFIG[subids] = "--enable-subordinate-ids"
PACKAGECONFIG:append = " subids"
