#!/bin/bash
## /etc/icinga2/scripts/host-by-mail.sh / 20160616
## Marianne Spiller <github@spiller.me>
## icinga2-2.4.10-1~ppa1~xenial1

Usage() {
  echo "host-by-mail notification script for Icinga2 by spillerm <github@spiller.me> 2016/06/16"
  echo "Used by icinga2 director and command 'alarm-host'."
}

while getopts a:b:c:d:hl:o:r:s:t: opt
do
  case "$opt" in
    a) HOSTADDRESS=$OPTARG ;;
    b) NAUTHOR=$OPTARG ;;
    c) NCOMMENT=$OPTARG ;;
    d) DATE=$OPTARG ;;
    h) Usage
       exit 1 ;;
    l) HOSTDN=$OPTARG ;;
    o) HOSTOUTPUT=$OPTARG ;;
    r) RECIPIENT=$OPTARG ;;
    s) HOSTSTATE=$OPTARG ;;
    t) NTYPE=$OPTARG ;;
    ?) echo "ERROR: invalid option" >&2
       exit 1 ;;
  esac
done

shift $((OPTIND - 1))

notification_message=`cat <<EOF
*****  spiller.me VM Icinga2 Host Monitoring  *****

==> $HOSTDN is $HOSTSTATE! <==

When?    $DATE
Host?    $HOSTDN
Address? $HOSTADDRESS
Info?    $HOSTOUTPUT

Comment by $NAUTHOR: $NCOMMENT

Have a look:
http://monitor.bafi.lan/icingaweb2/monitoring/host/show?host=$HOSTDN

EOF
`

/usr/bin/printf "%b" "$notification_message" | mail -s "$NTYPE alert for $HOSTDN - host state is $HOSTSTATE" $RECIPIENT
