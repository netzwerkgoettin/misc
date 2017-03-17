#!/bin/bash
## /etc/icinga2/scripts/service-by-mail.sh / 20160616
## Marianne M. Spiller <github@spiller.me>
## Last updated 20170316
## Tested 2.6.2-1~ppa1~xenial1 // https://www.unixe.de/icinga2-director-notifications/

PROG="`basename $0`"
HOSTNAME="`hostname`"

function Usage() {
cat << EOF

Usage, Usage!

EOF
exit 1;
}

while getopts a:b:c:d:e:f:hi:l:o:r:s:t:v: opt
do
  case "$opt" in
    a) HOSTADDRESS=$OPTARG ;;
    b) NOTIFICATIONAUTHORNAME=$OPTARG ;;
    c) NOTIFICATIONCOMMENT=$OPTARG ;;
    d) DATE=$OPTARG ;;
    e) SERVICENAME=$OPTARG ;;
    f) MAILFROM=$OPTARG ;;
    h) Usage ;;
    i) HAS_ICINGAWEB2=$OPTARG ;;
    l) HOSTALIAS=$OPTARG ;;
    o) SERVICEOUTPUT=$OPTARG ;;
    r) USEREMAIL=$OPTARG ;;
    s) SERVICESTATE=$OPTARG ;;
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
***** Icinga 2 Service Monitoring on $HOSTNAME *****

==> $SERVICENAME is $SERVICESTATE! <==

When?    $DATE
Service? $SERVICENAME
Host?    $HOSTALIAS ($HOSTADDRESS)
Info?    $SERVICEOUTPUT
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
  $HAS_ICINGAWEB2/monitoring/service/show?host=$HOSTALIAS&service=$SERVICENAME"
fi

## Build the message's subject
SUBJECT="[$NOTIFICATIONTYPE] $SERVICENAME on $HOSTALIAS is $SERVICESTATE!"

## Are we verbose? Then put a message to syslog...
if [ "$VERBOSE" == "true" ] ; then
  logger "$PROG sends $SUBJECT => $USEREMAIL"
fi

/usr/bin/printf "%b" "$NOTIFICATION_MESSAGE" \
| mail -a "From: $MAILFROM" -s "$SUBJECT" $USEREMAIL
