FROM debian:bookworm-slim

# Set environment variables for non-interactive apt operations
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    zstd \
    coreutils \
    util-linux \
    bc \
    kmod \
    --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/libexec

COPY os-helpers-fs os-helpers-logging /usr/libexec/

COPY test-zram-estimation.sh /usr/libexec/test-zram-estimation.sh

RUN chmod +x /usr/libexec/*

ENTRYPOINT ["/usr/libexec/test-zram-estimation.sh"]
