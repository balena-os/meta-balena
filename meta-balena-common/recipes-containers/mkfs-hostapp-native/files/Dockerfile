FROM debian:buster

VOLUME /mnt/sysroot/inactive

RUN apt-get update && apt-get install -y \
	ca-certificates \
	iptables \
	btrfs-progs \
	duperemove \
	rsync

COPY create.* /usr/bin/
