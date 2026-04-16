# in dunfell libuuid is still provided by util-linux so let's remove the dependency to this package that was introduced sometime after dunfell
DEPENDS_remove = "util-linux-libuuid"
