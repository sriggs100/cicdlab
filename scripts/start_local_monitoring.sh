#!/usr/bin/bash

# MIT License
# 
# Copyright (c) 2023 Sergio Andres Penen
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


touch /tmp/LAB_TEST_RUNNING
mkdir /var/log/monitor
OUT_FILE=/var/log/monitor/monitor_${HOSTNAME}.log


network_monitor()
{
	DEST_HOST=$1
	LOGFILE=$2

	while test -f /tmp/LAB_TEST_RUNNING
	do
		ping -c 100 $DEST_HOST >> $LOGFILE
	done
}


network_monitor_mtr()
{
	DEST_HOST=$1
	LOGFILE=$2

	while test -f /tmp/LAB_TEST_RUNNING
	do
		mtr -rwbzc100 $DEST_HOST >> $LOGFILE
	done
}


stats_monitor()
{
	LOGFILE=$1

	while test -f /tmp/LAB_TEST_RUNNING
	do
		vmstat 3 5 >> $LOGFILE
	done
}

print_timestamp()
{
	LOGFILE=$1

	while test -f /tmp/LAB_TEST_RUNNING
	do
		echo "TIMESTAMP: `date`" >> $LOGFILE
		
		sleep 15
	done
}

queue_monitor()
{
	LOGFILE=$1

	while test -f /tmp/LAB_TEST_RUNNING
	do
		TIMESTAMP=`date '+%Y%m%d%H%M%S'`
		
		curl 'http://localhost:8161/admin/xml/queues.jsp' -H 'Authorization: Basic YWRtaW46YWRtaW4=' 2>/dev/null |grep -E "queue name=|stats size=" | while read LINE 
		do 
			if [ "$STATE" != "S" ]
			then 
				TIMESTAMP_AND_NAME="$TIMESTAMP `echo $LINE | awk -F'"' '{ print $2 }'`"
				STATE=S
			else
				echo "$TIMESTAMP_AND_NAME `echo $LINE | awk -F'"' '{ print $2 }'`" >> $LOGFILE
				STATE=N
			fi
		done
		
		sleep 1
	done
}


if [ "$HOSTNAME" = "srv1" ]
then
#	network_monitor srv2 $OUT_FILE >/dev/null 2>&1 &
#	network_monitor_mtr srv2 $OUT_FILE >/dev/null 2>&1 &
#	network_monitor srv3 $OUT_FILE >/dev/null 2>&1 &
#	network_monitor_mtr srv3 $OUT_FILE >/dev/null 2>&1 &
	stats_monitor $OUT_FILE >/dev/null 2>&1 &
	print_timestamp $OUT_FILE >/dev/null 2>&1 &
else 
	if [ "$HOSTNAME" = "srv2" ]
	then
#		network_monitor srv1 $OUT_FILE >/dev/null 2>&1 &
#		network_monitor_mtr srv1 $OUT_FILE >/dev/null 2>&1 &
#		network_monitor srv3 $OUT_FILE >/dev/null 2>&1 &
#		network_monitor_mtr srv3 $OUT_FILE >/dev/null 2>&1 &
		stats_monitor $OUT_FILE >/dev/null 2>&1 &
		print_timestamp $OUT_FILE >/dev/null 2>&1 &
	else 
#		network_monitor srv1 $OUT_FILE >/dev/null 2>&1 &
#		network_monitor_mtr srv1 $OUT_FILE >/dev/null 2>&1 &
#		network_monitor srv2 $OUT_FILE >/dev/null 2>&1 &
#		network_monitor_mtr srv2 $OUT_FILE >/dev/null 2>&1 &
		stats_monitor $OUT_FILE >/dev/null 2>&1 &
		print_timestamp $OUT_FILE >/dev/null 2>&1 &
		queue_monitor $OUT_FILE >/dev/null 2>&1 &
	fi
fi

