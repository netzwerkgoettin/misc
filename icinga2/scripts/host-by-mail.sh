#!/bin/bash
## /etc/icinga2/scripts/host-by-mail.sh / 20160616
## Marianne M. Spiller <github@spiller.me>
## Last updated 20170316
## Tested 2.6.2-1~ppa1~xenial1 // https://www.unixe.de/icinga2-director-notifications/

PROG="`basename $0`"
HOSTNAME="`hostname`"

function Usage() {
cat << EOF

host-by-mail notification script for Icinga 2 by spillerm <github@spiller.me>
=> See https://docs.icinga.com/icinga2/latest/doc/module/icinga2/chapter/monitoring-basics

The following are mandatory:
  -a HOSTADDRESS (\$adress$)
  -d DATE (\$icinga.short_date_time$)
  -l HOSTALIAS (\$host.name$)
  -o HOSTOUTPUT (\$host.output$)
  -r USEREMAIL (\$user.email$)
  -s HOSTSTATE (\$host.state$)
  -t NOTIFICATIONTYPE (\$notification.type$)

And these are optional:
  -b NOTIFICATIONAUTHORNAME (\$notification.author$)
  -c NOTIFICATIONCOMMENT (\$notification.comment$)
  -i HAS_ICINGAWEB2 (\$icingaweb2url$, Default: unset)
  -f FROM (\$notification_mailfrom$, Default: "Icinga 2 Monitoring <icinga@$HOSTNAME>")
  -v (\$notification_sendtosyslog$, Default: false)

EOF

exit 1;
}

while getopts a:b:c:d:f:hi:l:o:r:s:t:v: opt
do
  case "$opt" in
    a) HOSTADDRESS=$OPTARG ;;
    b) NOTIFICATIONAUTHORNAME=$OPTARG ;;
    c) NOTIFICATIONCOMMENT=$OPTARG ;;
    d) DATE=$OPTARG ;;
    f) MAILFROM=$OPTARG ;;
    h) Usage ;;
    i) HAS_ICINGAWEB2=$OPTARG ;;
    l) HOSTALIAS=$OPTARG ;;
    o) HOSTOUTPUT=$OPTARG ;;
    r) USEREMAIL=$OPTARG ;;
    s) HOSTSTATE=$OPTARG ;;
    t) NOTIFICATIONTYPE=$OPTARG ;;
    v) VERBOSE=$OPTARG ;;
   \?) echo "ERROR: Invalid option -$OPTARG" >&2
       Usage ;;
    :) echo "Missing option argument for -$OPTARG" >&2
       Usage ;;
    *) echo "Unimplemented option: -$OPTARG" >&2
       Usage ;;
  esac
done

shift $((OPTIND - 1))

## Default sender address
if [ ! -n "$MAILFROM" ] ; then
  MAILFROM="Icinga 2 Monitoring <icinga@$HOSTNAME>"
fi

NOTIFICATION_MESSAGE=`cat << EOF
***** Icinga 2 Host Monitoring on $HOSTNAME *****

==> $HOSTALIAS is $HOSTSTATE! <==

When?    $DATE
Host?    $HOSTALIAS ($HOSTADDRESS)
Info?    $HOSTOUTPUT
EOF
`

## Are there any comments? Put them into the message!
if [ -n "$NOTIFICATIONCOMMENT" ] ; then
  NOTIFICATION_MESSAGE="$NOTIFICATION_MESSAGE

Comment by $NOTIFICATIONAUTHORNAME:
  $NOTIFICATIONCOMMENT"
fi

## Are we using Icinga Web 2? Put the URL into the message!
if [ -n "$HAS_ICINGAWEB2" ] ; then
  NOTIFICATION_MESSAGE="$NOTIFICATION_MESSAGE

Get live status:
  $HAS_ICINGAWEB2/monitoring/host/show?host=$HOSTALIAS"
fi

## Build the message's subject
SUBJECT="[$NOTIFICATIONTYPE] Host $HOSTALIAS is $HOSTSTATE!"

## Are we verbose? Then put a message to syslog...
if [ "$VERBOSE" == "true" ] ; then
  logger "$PROG sends $SUBJECT => $USEREMAIL"
fi

## And finally, send the message using mail command
/usr/bin/printf "%b" "$NOTIFICATION_MESSAGE" \
| mail -a "From: $MAILFROM" -s "$SUBJECT" $USEREMAIL 
