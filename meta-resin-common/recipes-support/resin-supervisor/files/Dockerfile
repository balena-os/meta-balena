FROM docker:1.10.3-dind

RUN apk add --update btrfs-progs bash util-linux && rm -rf /var/cache/apk/*

ADD entry.sh /entry.sh

RUN chmod a+x /entry.sh

CMD /entry.sh
