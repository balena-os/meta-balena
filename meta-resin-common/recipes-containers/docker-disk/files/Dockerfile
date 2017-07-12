FROM docker:17.03-dind

RUN apk add --update bash util-linux && rm -rf /var/cache/apk/*

ADD entry.sh /entry.sh

RUN chmod a+x /entry.sh

CMD /entry.sh
