FROM docker:1.4.1-dind

RUN apk add --update btrfs-progs bash && rm -rf /var/cache/apk/*

ADD entry.sh /entry.sh

RUN chmod a+x /entry.sh

CMD /entry.sh
