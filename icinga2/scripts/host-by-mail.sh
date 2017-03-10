#!/bin/bash
## /etc/icinga2/scripts/host-by-mail.sh / 20160616
## Marianne M. Spiller <github@spiller.me>
## Last updated 20170310
## Tested 2.6.2-1~ppa1~xenial1 // https://www.unixe.de/icinga2-director-notifications/

## Probably you'll have to change at least two of them to fit your needs
HOSTNAME="`hostname`"
MAILFROM="Icinga 2 Monitoring <icinga@example.com>"
MONITORING_URL="https://www.example.com/icingaweb2"

function Usage() {
cat << EOF

host-by-mail notification script for Icinga 2 by spillerm <github@spiller.me>
- Create a command (type: Notification Plugin Command) using this script as 'Command'
  => Take care of the command arguments!
- Then create notification templates using this command
- And now create notification objects and assign them as you want to
Have fun!

EOF
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

NOTIFICATION_MESSAGE=`cat << EOF
***** Icinga 2 Host Monitoring on $HOSTNAME *****

==> $HOSTDN is $HOSTSTATE! <==

When?    $DATE
Host?    $HOSTDN ($HOSTADDRESS)
Info?    $HOSTOUTPUT

Comment by $NAUTHOR: $NCOMMENT

Get live status:
$MONITORING_URL/monitoring/host/show?host=$HOSTDN

EOF
`

SUBJECT="[$NTYPE] Host $HOSTDN is $HOSTSTATE!"

/usr/bin/printf "%b" "$NOTIFICATION_MESSAGE" \
| mail -a "From: $MAILFROM" -s "$SUBJECT" $RECIPIENT


##------------------------------------------------------------
## object NotificationCommand "Host Alarm" {
##     import "plugin-notification-command"
##     command = [ "/etc/icinga2/scripts/host-by-mail.sh" ]
##     arguments += {
##         "-a" = "$address$"
##         "-b" = "$notification.author$"
##         "-c" = "$notification.comment$"
##         "-d" = "$icinga.short_date_time$"
##         "-l" = "$host.name$"
##         "-o" = "$host.output$"
##         "-r" = "$user.email$"
##         "-s" = "$host.state$"
##         "-t" = "$notification.type$"
##     }
## }
## 
## template Notification "Generic Host Alarm" {
##   command = "Host Alarm"
##   interval = 0s
##   states = [ Down, Up ]
##   types = [ Recovery, Acknowledgement, Custom, Problem ]
## }
##
## apply Notification "Notify my team about host" to Host {
##   import "Generic Host Alarm"
## 
##   period = "always"
##   user_groups = [ "the_people" ]
##   interval = 4h
## 
##   assign where true
##   ignore where "External Hosts" in host.templates
## }
