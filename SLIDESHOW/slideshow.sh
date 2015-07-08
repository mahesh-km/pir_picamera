#!/bin/sh

PATH=/home/pi/BAY
INTERVAL=2
EXTENSION="JPG"

start_slide() {
   /usr/bin/fbi -a -noverbose -T 1 -t $INTERVAL ${PATH}/*.$EXTENSION
}

stop_slide() {
   /usr/bin/pkill fbi
}

if [ "$#" -ne 1 ]; then
   echo "USAGE: $0 start|stop" >&2
   exit 1
else
   ACTION=$1
   if [ $ACTION = "start" ]; then
      start_slide
   elif [ $ACTION = "stop" ]; then
      stop_slide
  fi
fi


