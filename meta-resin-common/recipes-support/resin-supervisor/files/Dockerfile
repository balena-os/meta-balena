FROM ubuntu:14.04

RUN apt-get update && apt-get install btrfs-tools curl apt-transport-https -y \
	&& curl -sSL https://get.docker.com/ubuntu/ | sh

ADD entry.sh /entry.sh

RUN chmod a+x /entry.sh

CMD /entry.sh
