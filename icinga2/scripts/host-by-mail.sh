#!/usr/bin/env bash
## Created 20160616 / Last updated 20170405
## Marianne M. Spiller <github@spiller.me>
## Tested 2.6.3-1~ppa1~xenial1 // https://www.unixe.de/icinga2-director-notifications/

PROG="`basename $0`"
HOSTNAME="`hostname`"
MAILBIN="sendmail"

if [ -z "`which $MAILBIN`" ] ; then
  echo "$MAILBIN not in \$PATH. Consider installing it."
  exit 1
fi

function Usage() {
cat << EOF

The following are mandatory:
  -4 HOSTADDRESS (\$address$)
  -6 HOSTADDRESS6 (\$address6$)
  -d LONGDATETIME (\$icinga.long_date_time$)
  -l HOSTALIAS (\$host.name$)
  -n HOSTDISPLAYNAME (\$host.display_name$)
  -o HOSTOUTPUT (\$host.output$)
  -r USEREMAIL (\$user.email$)
  -s HOSTSTATE (\$host.state$)
  -t NOTIFICATIONTYPE (\$notification.type$)

And these are optional:
  -b NOTIFICATIONAUTHORNAME (\$notification.author$)
  -c NOTIFICATIONCOMMENT (\$notification.comment$)
  -i ICINGAWEB2URL (\$icingaweb2url$, Default: unset)
  -f MAILFROM (\$notification_mailfrom$, Default: "Icinga 2 Monitoring <icinga@$HOSTNAME>")
  -v VERBOSE (\$notification_sendtosyslog$)

EOF

exit 1;
}

while getopts 4:6::b:c:d:f:hi:l:n:o:r:s:t:v: opt
do
  case "$opt" in
    4) HOSTADDRESS=$OPTARG ;;
    6) HOSTADDRESS6=$OPTARG ;;
    b) NOTIFICATIONAUTHORNAME=$OPTARG ;;
    c) NOTIFICATIONCOMMENT=$OPTARG ;;
    d) LONGDATETIME=$OPTARG ;;
    f) MAILFROM=$OPTARG ;;
    h) Usage ;;
    i) ICINGAWEB2URL=$OPTARG ;;
    l) HOSTALIAS=$OPTARG ;;
    n) HOSTDISPLAYNAME=$OPTARG ;;
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

## Build the message's subject
SUBJECT="[$NOTIFICATIONTYPE] Host $HOSTDISPLAYNAME is $HOSTSTATE!"

## Build the notification message
NOTIFICATION_MESSAGE=`cat << EOF
Content-Type: text/plain
Subject: $SUBJECT
To: $USEREMAIL
From: $MAILFROM
***** Icinga 2 Host Monitoring on $HOSTNAME *****

==> $HOSTDISPLAYNAME ($HOSTALIAS) is $HOSTSTATE! <==

Info?    $HOSTOUTPUT

When?    $LONGDATETIME
Host?    $HOSTALIAS (aka "$HOSTDISPLAYNAME)
IPv4?	 $HOSTADDRESS
EOF
`

## Is this host IPv6 capable? Put its address into the message.
if [ -n "$HOSTADDRESS6" ] ; then
  NOTIFICATION_MESSAGE="$NOTIFICATION_MESSAGE
IPv6?	 $HOSTADDRESS6"
fi

## Are there any comments? Put them into the message.
if [ -n "$NOTIFICATIONCOMMENT" ] ; then
  NOTIFICATION_MESSAGE="$NOTIFICATION_MESSAGE

Comment by $NOTIFICATIONAUTHORNAME:
  $NOTIFICATIONCOMMENT"
fi

## Are we using Icinga Web 2? Put the URL into the message.
if [ -n "$ICINGAWEB2URL" ] ; then
  NOTIFICATION_MESSAGE="$NOTIFICATION_MESSAGE

Get live status:
  $ICINGAWEB2URL/monitoring/host/show?host=$HOSTALIAS"
fi

## Are we verbose? Then put a message to syslog.
if [ "$VERBOSE" == "true" ] ; then
  logger "$PROG sends $SUBJECT => $USEREMAIL"
fi

## And finally: send the message using sendmail command.
/usr/bin/printf "%b" "$NOTIFICATION_MESSAGE" | $MAILBIN -t
