FROM alpine:3.11

RUN apk --update add --no-cache openssh bash \
  && rm -rf /var/cache/apk/*

COPY docker-entrypoint.sh /root/
RUN chmod +x /root/docker-entrypoint.sh

WORKDIR /root

ENTRYPOINT ["/root/docker-entrypoint.sh"]
