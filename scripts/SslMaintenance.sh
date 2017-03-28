#!/usr/bin/env bash
# SslMaintenance.sh / 20170205
# Marianne M. Spiller <github@spiller.me>
# Helps me a lot to maintain letsencrypt and TLSA crap

PROG="$(basename $0)"

## Email Settings
MAILFROM="noreply@unixe.de"
MAILTO="marianne@spiller.me"
SUBJECT="Weekly SSL Maintenance on $(hostname)"
MAIL_TXT="/tmp/.$PROG"

LETSENCRYPT="/etc/letsencrypt/live"
SSL_DOMAINS=`ls $LETSENCRYPT`
TLSA_BIN="/usr/src/hash-slinger-2.7/tlsa"

echo $SUBJECT > $MAIL_TXT
echo "=================================================================" >> $MAIL_TXT
echo "" >> $MAIL_TXT

for i in $SSL_DOMAINS ; do
  echo "-- $i --" >> $MAIL_TXT
  VALID_UNTIL=`openssl x509 -dates -noout < $LETSENCRYPT/$i/fullchain.pem | grep notAfter | cut -d '=' -f 2`
  echo "Valid until: $VALID_UNTIL" >> $MAIL_TXT

  DNS_FOR_DOMAIN=`dig $i ns +short |  head -n 1`

  TLSA_RECORD_ACTUAL=`$TLSA_BIN --usage 3 --selector 0 --mtype 1 --output rfc --certificate $LETSENCRYPT/$i/fullchain.pem $i | tail -n 1 | cut -d ' ' -f 7 | tr '[:lower:]' '[:upper:]'`
  echo "$TLSA_RECORD_ACTUAL => TLSA record for this certificate" >> $MAIL_TXT

  TLSA_RECORD_DNS=`dig _443._tcp.$i IN TLSA +short | cut -d ' ' -f 4,5 | tr -d ' '`
  if [ "x$TLSA_RECORD_DNS" != "x" ] ; then
	echo "$TLSA_RECORD_DNS => Actual TLSA entry in DNS (on $DNS_FOR_DOMAIN)" >> $MAIL_TXT
	if [ "$TLSA_RECORD_ACTUAL" == "$TLSA_RECORD_DNS" ] ; then
	  echo "=> TLSA records match: YES!" >> $MAIL_TXT
	else
	  echo "=> TLSA records match: --NO!--" >> $MAIL_TXT
	fi
  else
	echo "=> TLSA records completly UNSET for $i (on $DNS_FOR_DOMAIN). <=" >> $MAIL_TXT
  fi

  echo "" >> $MAIL_TXT
done

mailx -a "From: $MAILFROM" -s "$SUBJECT" $MAILTO < $MAIL_TXT 

rm $MAIL_TXT
