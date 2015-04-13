#!/bin/sh

### BEGIN INIT INFO
# Provides:          app
# Required-Start:    
# Required-Stop:     
# Should-Start:      
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: start App MJPG_ENCODER
### END INIT INFO

MJPG_ENCODER_NAME=mjpg-encoder-ov7670
MJPG_ENCODER_PATH=/etc/trik/sensors/$MJPG_ENCODER_NAME
MJPG_ENCODER_PRIORITY=-1
 
MJPG_ENCODER_PIDDIR=/var/run/
MJPG_ENCODER_PID=$PIDDIR/$NAME.pid

. /etc/init.d/functions

test -x $MJPG_ENCODER_PATH/$NAME || exit 0

#include default options
test -f /etc/default/$MJPG_ENCODER_NAME.default && . /etc/default/$MJPG_ENCODER_NAME.default 


enviroment () {
        export LD_LIBRARY_PATH=$MJPG_ENCODER_PATH:$LD_LIBRARY_PATH
        cd $MJPG_ENCODER_PATH

}

set_cam() {
  /etc/trik/init-ov7670-320x240.sh $VIDEO_CH
}

fix_cam() {      
  case $VIDEO_CH in  
    0)
      i2cset -y 0x1 0x21 0x13 0x87
      ;;
    1)
      i2cset -y 0x2 0x21 0x13 0x87
      ;;
  esac
}

clean_caches_plug() {
  echo 1 > /proc/sys/vm/drop_caches
  echo 2 > /proc/sys/vm/drop_caches
  echo 3 > /proc/sys/vm/drop_caches
}

do_start() {
  clean_caches_plug
  enviroment
  set_cam
  start-stop-daemon -Svb -x ./$MJPG_ENCODER_NAME -- $DEFAULT_OPS
  #wait for stabilized exposure:
  sleep 1
  #just fix exposure:
  fix_cam
  sleep 1
  status ./$MJPG_ENCODER_NAME
  exit $?
}

do_stop() {
  start-stop-daemon -Kvx ./$MJPG_ENCODER_NAME
}

case $1 in 
        start)
                echo -n "Starting  $MJPG_ENCODER_NAME daemon : "
                do_start
                ;;
        stop)
                echo -n "Stopping $MJPG_ENCODER_NAME daemon: "
                do_stop
                ;;
        restart|force-reload)
                echo -n "Restarting $MJPG_ENCODER_NAME daemon: "
                do_stop
                do_start
                ;;
        status)
                enviroment 
                status ./$MJPG_ENCODER_NAME
                exit $?
                ;;
        *)
                echo "Usage: $0 {start|stop|force-reload|restart|status}"
                exit 1
        ;;
esac
exit 0

