#!/bin/bash
## JpegOptimize.sh / 20150902
## Marianne Spiller <github@spiller.me>
## jpegoptim v1.4.1, libjpeg version: 6b 

# Einmal pro Woche ausgefuehrt optimiert der Aufruf alle JP(E)Gs
# unterhalb /var/www, die seit dem letzten Aufruf hinzugefuegt 
# wurden

PROG=`basename $0`
WWWFILES="/var/www/"
LASTRUN="/var/run/$PROG.lastrun"

find $WWWFILES \
-iname \*.jp*g \
-newer $LASTRUN \
-type f -print0 \
| xargs -0 /usr/local/bin/jpegoptim -t -s --all-progressive

touch $LASTRUN
