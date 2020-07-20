#!/bin/sh
#
# Legacy action script to visually check if nginx fails to reload

# Source function library.
[ -f /etc/rc.d/init.d/functions ] && . /etc/rc.d/init.d/functions

prog=nginx-quic
pidfile=`/usr/bin/systemctl show -p PIDFile nginx-quic.service | sed 's/^PIDFile=//' | tr ' ' '\n'`
CHECKSLEEP=3

templog=`/bin/mktemp --tmpdir nginx-check-reload-XXXXXX.log`
trap '/bin/rm -f $templog' 0
/usr/bin/tail --pid=$$ -n 0 --follow=name /var/log/nginx-quic/error.log > $templog &
/bin/sleep 1
/bin/echo -n $"Sending reload signal to $prog: "
killproc -p ${pidfile} ${prog} -HUP
/bin/echo
/bin/sleep $CHECKSLEEP
/bin/grep -E "\[emerg\]|\[alert\]" $templog

exit 0
