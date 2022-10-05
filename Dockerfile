FROM alpine:latest
RUN apk add --no-cache gnupg curl jq

WORKDIR /

ADD verify.sh /verify.sh
RUN chmod +x /verify.sh

ENTRYPOINT ["sh", "verify.sh"]
