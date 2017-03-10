#!/bin/bash
## /etc/icinga2/scripts/service-by-mail.sh / 20160616
## Marianne M. Spiller <github@spiller.me>
## Last updated 20170309
## Tested 2.6.2-1~ppa1~xenial1 // https://www.unixe.de/icinga2-director-notifications/

## Probably you'll have to change at least two of them to fit your needs
HOSTNAME="`hostname`"
MAILFROM="Icinga 2 Monitoring <icinga@example.com>"
MONITORING_URL="https://www.example.com/icingaweb2"

function Usage() {
cat << EOF

service-by-mail notification script for Icinga 2 by spillerm <github@spiller.me>
- Create a command (type: Notification Plugin Command) using this script as 'Command'
  => Take care of the command arguments!
- Then create notification templates using this command
- And now create notification objects and assign them as you want to
Have fun!

EOF
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

NOTIFICATION_MESSAGE=`cat << EOF
***** Icinga 2 Service Monitoring on $HOSTNAME *****

==> $SERVICENAME is $SERVICESTATE! <==

When?    $DATE
Service? $SERVICENAME
Host?    $HOSTDN ($HOSTADDRESS)
Info?    $SERVICEOUTPUT

Comment by $NAUTHOR: $NCOMMENT

Have a look:
$MONITORING_URL/monitoring/service/show?host=$HOSTDN&service=$SERVICENAME

EOF
`

SUBJECT="[$NTYPE] $SERVICENAME on $HOSTDN is $SERVICESTATE!"

/usr/bin/printf "%b" "$NOTIFICATION_MESSAGE" \
| mail -a "From: $MAILFROM" -s "$SUBJECT" $RECIPIENT

##--------------------------------------------------------------------
## object NotificationCommand "Service Alarm" {
##     import "plugin-notification-command"
##     command = [ "/etc/icinga2/scripts/service-by-mail.sh" ]
##     arguments += {
##         "-a" = "$address$"
##         "-b" = "$notification.author$"
##         "-c" = "$notification.comment$"
##         "-d" = "$icinga.short_date_time$"
##         "-e" = "$service.name$"
##         "-l" = "$host.name$"
##         "-o" = "$service.output$"
##         "-r" = "$user.email$"
##         "-s" = "$service.state$"
##         "-t" = "$notification.type$"
##     }
## }
##
## template Notification "Generic Service Alarm" {
##   command = "Service Alarm"
##   interval = 6h
##   states = [ Critical, OK, Warning ]
##   types = [ Acknowledgement, Custom, Problem, Recovery ]
## }
##
## apply Notification "Notify my team about service" to Service {
##   import "Generic Service Alarm"
##   period = "always"
##   user_groups = [ "the_people" ]
##   interval = 24h
## 
##   assign where true
##   ignore where "External Hosts" in host.templates
## }
