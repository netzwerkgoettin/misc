#!/bin/bash
## CCU2_Encode.sh / 20150920
## Marianne Spiller <github@spiller.me>
## Korrekte Darstellung von Umlauten, wenn die CCU2 Nachrichten verschickt

if [ $# -ne 1 ]
then
  echo "Usage: `basename $0` \"{string}\""
  exit 1
fi

printf "%-15s" 'String CCU2:' ; python -c "import urllib; print urllib.quote('''$1''')"
