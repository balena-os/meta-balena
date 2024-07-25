FROM docker:27.1.1-dind
RUN apk add --update util-linux shadow e2fsprogs jq curl && rm -rf /var/cache/apk/*
COPY entry.sh balena-api.inc /
RUN chmod a+x /entry.sh

VOLUME /resin-data

CMD /entry.sh
