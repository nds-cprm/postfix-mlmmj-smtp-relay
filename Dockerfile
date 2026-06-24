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

COPY --chmod=0644 ./conf/main.cf /etc/postfix

COPY --chmod=0644 ./conf/master.cf /etc/postfix

COPY --chmod=0755 ./conf/mlmmj.conf.sh .

ENV  MYDOMAIN=mydomain.com

RUN  /mlmmj.conf.sh

RUN  rm mlmmj.conf.sh

COPY --chmod=0750 ./docker-entrypoint.sh /

ENV RELAY_HOST=smtp.gmail.com \
    RELAY_PORT=587 \
    SASL_PASSWD_FILE=/etc/postfix/sasl_passwd

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD ["postfix", "start-fg"]

