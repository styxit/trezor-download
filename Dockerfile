FROM alpine:latest
RUN apk add --no-cache gnupg
RUN apk add --no-cache curl
RUN apk add --no-cache jq

WORKDIR /

ADD verify.sh /verify.sh
RUN chmod +x /verify.sh

ENTRYPOINT ["sh", "verify.sh"]
