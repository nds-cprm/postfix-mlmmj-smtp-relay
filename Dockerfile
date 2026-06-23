FROM debian:trixie-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
        ca-certificates \
        libsasl2-2 \
        libsasl2-modules \
        mailutils \
	postfix \
        postfix-pcre \
        mlmmj && \
    apt-get autoremove && \
    rm -rf /varlib/apt/lists/* 

COPY docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

ENV RELAY_HOST=smtp.gmail.com \
    RELAY_PORT=587 \
    SASL_PASSWD_FILE=/etc/postfix/sasl_passwd

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD ["postfix", "start-fg"]
