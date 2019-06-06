FROM debian:stretch

VOLUME /mnt/sysroot/inactive

RUN apt-get update && apt-get install -y \
	ca-certificates \
	iptables

COPY create /usr/bin/

CMD [ "/usr/bin/create" ]
