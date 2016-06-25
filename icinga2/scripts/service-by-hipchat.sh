#!/bin/bash
## /etc/icinga2/scripts/host-by-mail.sh / 20160616
## Marianne Spiller <github@spiller.me>
## icinga2-2.4.10-1~ppa1~xenial1

ROOM_ID="..."
AUTH_TOKEN="..."

Usage() {
  echo "service-by-hipchat notification script for Icinga2 by spillerm <github@spiller.me> 2016/06/25"
  echo "- Get your HipChat RoomID and create an AUTH_TOKEN named Icinga2."
  echo "- Put this script in /etc/icinga2/scripts"
  echo "- Create a command (eg. alarm-service-by-hipchat) and take care of its arguments"
  echo "- Create a notification (eg. hipchat-service)"
  echo "- Create apply rules and perhaps a generic HipChat user, assign it, have fun."
}

while getopts a:b:c:e:f:hl:o:s:t: opt
do
  case "$opt" in
    a) ## $address$
       HOSTADDRESS=$OPTARG ;;
    b) ## $notification.author$
       NAUTHOR=$OPTARG ;;
    c) ## $notification.comment$
       NCOMMENT=$OPTARG ;;
    e) ## $service.name$
       SERVICENAME=$OPTARG ;;
    f) ## $service.display_name$
       SERVICEDN=$OPTARG ;;
    h) Usage
       exit 1 ;;
    l) ## $host.name$
       HOSTDN=$OPTARG ;;
    o) ## $service.output$
       SERVICEOUTPUT=$OPTARG ;;
    s) ## $service.state$
       SERVICESTATE=$OPTARG ;;
    t) ## $notification.type$
       NTYPE=$OPTARG ;;
    ?) echo "ERROR: invalid option" >&2
       exit 1 ;;
  esac
done

shift $((OPTIND - 1))

if [ "x$NCOMMENT" != "x" ] ; then
  USERCOMMENT="[Comment by $NAUTHOR: $NCOMMENT]"
else
  USERCOMMENT=""
fi

## Default color is yellow.
if [ "$SERVICESTATE" = "OK" ] ; then
  PUSHMSG="true"
  COLOR="green"
  HIPCHATMSG="@all Yay, $SERVICEDN ($SERVICENAME) on $HOSTDN ($HOSTADDRESS) is $SERVICESTATE again :D $USERCOMMENT"
elif [ "$SERVICESTATE" = "Critical" ] ; then
  PUSHMSG="true"
  COLOR="red"
  HIPCHATMSG="@all Oh no! $SERVICEDN ($SERVICENAME) on $HOSTDN ($HOSTADDRESS) is $SERVICESTATE now... :'( $USERCOMMENT"
else
  PUSHMSG="false"
  HIPCHATMSG="$SERVICEDN ($SERVICENAME) on $HOSTDN ($HOSTADDRESS) is $SERVICESTATE. $USERCOMMENT"
  COLOR="purple"
fi

curl -H "Content-Type: application/json" \
     -X POST \
     -d "{\"color\": \"$COLOR\", \"notify\": \"$PUSHMSG\", \"message_format\": \"text\", \"message\": \"$HIPCHATMSG\" }" \
     https://api.hipchat.com/v2/room/$ROOM_ID/notification?auth_token=$AUTH_TOKEN 
