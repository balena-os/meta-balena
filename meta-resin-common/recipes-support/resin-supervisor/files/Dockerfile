FROM docker:1.6.2-dind

RUN apk add --update btrfs-progs bash util-linux && rm -rf /var/cache/apk/*

ADD entry.sh /entry.sh

RUN chmod a+x /entry.sh

CMD /entry.sh
