# Shared resin-data partition settings (docker-disk seed + balenaos-img mkfs).
BALENA_DATA_PARTITION_SIZE_MB ?= "256"
BALENA_DATA_FS_BLOCK_SIZE ?= "4k"
BALENA_DATA_STAGING ?= "resin-data-staging.tar"
