#!/bin/bash
## /etc/icinga2/scripts/service-by-mail.sh / 20160616
## Marianne Spiller <github@spiller.me>
## icinga2-2.4.10-1~ppa1~xenial1

Usage() {
  echo "service-by-mail notification script for Icinga2 by spillerm <github@spiller.me> 2016/06/16"
  echo "Used by icinga2 director and command 'alarm-service'."
}

while getopts a:b:c:d:e:hl:o:r:s:t: opt
do
  case "$opt" in
    a) HOSTADDRESS=$OPTARG ;;
    b) NAUTHOR=$OPTARG ;;
    c) NCOMMENT=$OPTARG ;;
    d) DATE=$OPTARG ;;
    e) SERVICENAME=$OPTARG ;;
    h) Usage
       exit 1 ;;
    l) HOSTDN=$OPTARG ;;
    o) SERVICEOUTPUT=$OPTARG ;;
    r) RECIPIENT=$OPTARG ;;
    s) SERVICESTATE=$OPTARG ;;
    t) NTYPE=$OPTARG ;;
    ?) echo "ERROR: invalid option" >&2
       exit 1 ;;
  esac
done

shift $((OPTIND - 1))

notification_message=`cat <<EOF
*****  spiller.me VM Icinga2 Service Monitoring  *****

==> $SERVICENAME is $SERVICESTATE! <==

When?    $DATE
Service? $SERVICENAME
Host?    $HOSTDN
Address? $HOSTADDRESS
Info?    $SERVICEOUTPUT

Comment by $NAUTHOR: $NCOMMENT

Have a look:
http://monitor.bafi.lan/icingaweb2/monitoring/service/show?host=$HOSTDN&service=$SERVICENAME

EOF
`

/usr/bin/printf "%b" "$notification_message" | mail -s "$NTYPE alert for $SERVICENAME - service state is $SERVICESTATE" $RECIPIENT
