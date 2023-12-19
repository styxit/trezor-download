FROM alpine:3

RUN apk add --no-cache gnupg curl jq
RUN apk add --no-cache gum

WORKDIR /

ADD verify.sh /verify.sh
RUN chmod +x /verify.sh

ENTRYPOINT ["sh", "verify.sh"]
