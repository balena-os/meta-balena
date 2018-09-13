# Since gcc 7.3.0, compiling mobynit with pie support fails at runtime. We
# deactivate it until we figure out why that happens.
MOBYNIT_EXTRA_LDFLAGS_append = " -no-pie"
