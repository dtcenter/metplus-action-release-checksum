FROM alpine:latest

RUN apk add --update --no-cache curl bash

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
