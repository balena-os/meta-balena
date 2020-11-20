FROM debian:buster

VOLUME /mnt/sysroot/inactive

RUN apt-get update && apt-get install -y \
	ca-certificates \
	iptables \
	squashfs-tools

COPY create.* /usr/bin/
