#!/usr/bin/bash

# create a user for mlmmj

useradd -r -u 72 -b /var/spool -M -s /usr/sbin/nologin mlmmj

mkdir -p /var/spool/mlmmj

chmod -R 770 /var/spool/mlmmj

chown mlmmj:mlmmj /var/spool/mlmmj

#
# create example list, ( must repeat for each list )
#
# mlmmj-make-ml -L mylist -s /var/spool/mlmmj -c mlmmj:mlmmj -a
#

# Configure postfix

cat << EOT >> /etc/postfix/main.cf
#
# ====================================================================
# mlmmj mailing lists
#
# Enable '+' as the standard mlmmj recipient delimiter
recipient_delimiter = +

# Ensure mlmmj processes messages individually per list
mlmmj_destination_recipient_limit = 1

# Allow virtual alias maps to specify only the user part of the address
# and have the +extension part preserved when forwarding, so that
# list-name+subscribe, list-name+confsub012345678, etc. will all work
propagate_unmatched_extensions = virtual

# A map to forward mail for a dummy domain to the mlmmj transport
transport_maps = lmdb:/var/spool/mlmmj/transport

# A map to forward mail to a dummy domain
virtual_alias_maps = lmdb:/var/spool/mlmmj/virtual

EOT

cat << EOT >> /etc/postfix/master.cf
#
# ====================================================================
# mlmmj mailing lists
#
mlmmj   unix  -       n       n       -       -       pipe
    flags=DORhu user=mlmmj argv=/usr/local/bin/mlmmj-receive -F -L /var/spool/mlmmj/$nexthop

EOT

#
# those maps in /var/spool/mlmmj as defined above
# but could be in /etc/postfix,
#

# suport for each single list

cat << EOT >> /var/spool/mlmmj/transport
mylist.yourdomain.com   mlmmj:

EOT

cat << EOT >> /var/spool/mlmmj/virtual
mylist@yourdomain.com        mylist
mylist+subscribe@yourdomain.com        mylist
mylist+unsubscribe@yourdomain.com      mylist

EOT

# suport for multiple lists using regex

cat << EOT >> /var/spool/mlmmj/transport.pcre
# Captura o nome da lista e envia como $nexthop
/^([a-zA-Z0-9_\-]+)@yourdomain\.com$/    mlmmj:${1}

EOT

cat << EOT >> /var/spool/mlmmj/virtual.pcre
# Redireciona comandos com "+" de volta para a lista principal
/^([a-zA-Z0-9_\-]+)\+[a-zA-Z0-9_\-]+@yourdomain\.com$/    ${1}@yourdomain.com

EOT

cat << EOT >> /var/spool/mlmmj/main.cf
transport_maps = pcre:/var/spool/mlmmj/transport.pcre
virtual_alias_maps = pcre:/var/spool/mlmmj/virtual.pcre

EOT

# remaps

postmap /var/spool/mlmmj/transport

postmap /var/spool/mlmmj/virtual


