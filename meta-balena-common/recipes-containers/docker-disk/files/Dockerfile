FROM docker:19.03.10-dind
RUN apk add --update util-linux shadow e2fsprogs mtd-utils && rm -rf /var/cache/apk/*
ADD entry.sh /entry.sh
RUN chmod a+x /entry.sh

VOLUME /resin-data

CMD /entry.sh
