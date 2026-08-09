DESCRIPTION = "Tracing hostapp extension"
LICENSE = "MIT"

inherit balena-hostapp-extension balena-tracing

# Lower values win, so the kernel extension at 100 shadows this one.
HOSTAPP_EXTENSION_LABEL_OVERRIDE = "200"
