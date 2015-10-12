#!/bin/bash
## AddLdapEntry.sh / 20151012
## Marianne Spiller <github@spiller.me>

ldapadd \
-x \
-D 'cn=papaschlumpf,dc=sysadmama,dc=de' \
-w `cat /etc/ldap/ldap.secret` \
-f $1
