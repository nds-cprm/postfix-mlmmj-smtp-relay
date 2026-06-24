#!/bin/bash
set -e

_RELAY_SERVER="[$RELAY_HOST]:$RELAY_PORT"

# Identificação do servidor de email
if [[ -e "$EMAIL_NAME" ]]; then
    echo "$(whoami): $EMAIL_NAME" >> /etc/aliases
    newaliases
fi

if [[ -e "$EMAIL_SENDER" ]]; then
    echo "$EMAIL_SENDER" >> /etc/mailname
fi

# Gera o arquivo SASL_passwd
echo "$_RELAY_SERVER    $RELAY_USER:$RELAY_PASSWORD" > $SASL_PASSWD_FILE

# Atualiza parâmetros de postconf
postconf -e "compatibility_level=3.6" \
    "relayhost = $_RELAY_SERVER" \
    "maillog_file = /dev/stdout" \
    "smtp_sasl_auth_enable = yes" \
    "smtp_sasl_password_maps = lmdb:$SASL_PASSWD_FILE"

# Gera o banco de dados de autenticação criptografado
postmap $SASL_PASSWD_FILE

# Remove o arquivo de texto plano por segurança (o Postfix usará apenas o .db)
rm -f $SASL_PASSWD_FILE

# Garante permissões corretas na fila do Postfix
postfix check

exec "$@"
