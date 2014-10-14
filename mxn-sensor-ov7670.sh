#!/bin/sh

### BEGIN INIT INFO
# Provides:          app
# Required-Start:    
# Required-Stop:     
# Should-Start:      
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: start App MXN_SENSOR
### END INIT INFO

MXN_SENSOR_NAME=mxn-sensor-ov7670
MXN_SENSOR_PATH=/etc/trik/sensors/$MXN_SENSOR_NAME
MXN_SENSOR_PRIORITY=-1
 
MXN_SENSOR_PIDDIR=/var/run/
MXN_SENSOR_PID=$PIDDIR/$NAME.pid

. /etc/init.d/functions

test -x $MXN_SENSOR_PATH/$NAME || exit 0

#include default options
test -f /etc/default/$MXN_SENSOR_NAME.default && . /etc/default/$MXN_SENSOR_NAME.default 


enviroment () {
        export LD_LIBRARY_PATH=$MXN_SENSOR_PATH:$LD_LIBRARY_PATH
        cd $MXN_SENSOR_PATH

}

set_cam() {
  /etc/trik/init-ov7670-320x240.sh $VIDEO_CH
}

fix_cam() {                                                      
  case $VIDEO_CH in  
    0)
      i2cset -y 0x1 0x21 0x13 0x86
      ;;
    1)
      i2cset -y 0x2 0x21 0x13 0x86
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
  start-stop-daemon -Svb -x ./$MXN_SENSOR_NAME -- $DEFAULT_OPS
  #wait for stabilized exposure:
  sleep 1
  #just fix exposure:
  fix_cam
  status ./$MXN_SENSOR_NAME
  exit $?
}

do_stop() {
  start-stop-daemon -Kvx ./$MXN_SENSOR_NAME
}

case $1 in 
        start)
                echo -n "Starting  $MXN_SENSOR_NAME daemon : "
                do_start
                ;;
        stop)
                echo -n "Stopping $MXN_SENSOR_NAME daemon: "
                do_stop
                ;;
        restart|force-reload)
                echo -n "Restarting $MXN_SENSOR_NAME daemon: "
                do_stop
                do_start
                ;;
        status)
                enviroment 
                status ./$MXN_SENSOR_NAME
                exit $?
                ;;
        *)
                echo "Usage: $0 {start|stop|force-reload|restart|status}"
                exit 1
        ;;
esac
exit 0

