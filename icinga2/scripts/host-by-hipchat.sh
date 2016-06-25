#!/bin/bash
## /etc/icinga2/scripts/host-by-mail.sh / 20160616
## Marianne Spiller <github@spiller.me>
## icinga2-2.4.10-1~ppa1~xenial1

ROOM_ID="..."
AUTH_TOKEN="..."

Usage() {
  echo "host-by-hipchat notification script for Icinga2 by spillerm <github@spiller.me> 2016/06/24"
  echo "- Get your HipChat RoomID and create an AUTH_TOKEN named Icinga2."
  echo "- Put this script in /etc/icinga2/scripts"
  echo "- Create a command (eg. alarm-host-by-hipchat) and take care of its arguments"
  echo "- Create a notification (eg. hipchat-host)"
  echo "- Create apply rules and perhaps a generic HipChat user, assign it, have fun."
}

while getopts a:b:c:hl:o:s:t: opt
do
  case "$opt" in
    a) ## $address$
       HOSTADDRESS=$OPTARG ;;
    b) ## $notification.author$
       NAUTHOR=$OPTARG ;;
    c) ## $notification.comment$
       NCOMMENT=$OPTARG ;;
    h) Usage
       exit 1 ;;
    l) ## $host.name$
       HOSTDN=$OPTARG ;;
    o) ## $host.output$
       HOSTOUTPUT=$OPTARG ;;
    s) ## $host.state$
       HOSTSTATE=$OPTARG ;;
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
if [ "$HOSTSTATE" = "UP" ] ; then
  PUSHMSG="true"
  COLOR="green"
  HIPCHATMSG="@all Yay, $HOSTDN ($HOSTADDRESS) is $HOSTSTATE again. :D $USERCOMMENT"
elif [ "$HOSTSTATE" = "DOWN" ] ; then
  PUSHMSG="true"
  COLOR="red"
  HIPCHATMSG="@all Oh no! $HOSTDN ($HOSTADDRESS) is $HOSTSTATE now. :'( $USERCOMMENT"
else
  PUSHMSG="false"
  HIPCHATMSG="$HOSTDN ($HOSTADDRESS) is $HOSTSTATE. $USERCOMMENT"
  COLOR="purple"
fi

curl -H "Content-Type: application/json" \
     -X POST \
     -d "{\"color\": \"$COLOR\", \"notify\": \"$PUSHMSG\", \"message_format\": \"text\", \"message\": \"$HIPCHATMSG\" }" \
     https://api.hipchat.com/v2/room/$ROOM_ID/notification?auth_token=$AUTH_TOKEN 
