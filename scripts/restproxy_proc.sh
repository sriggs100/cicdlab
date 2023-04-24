#!/usr/bin/bash

ENVIRONMENT_STOP_FILE=/tmp/ENV_STOPPED

LOGFILE=/var/log/acq/acqrestproxy.log
SCRNAME=`basename $0`


while true
do 
	echo "`date` $SCRNAME - STARTING INSTANCE"	>> $LOGFILE

	[ -f $ENVIRONMENT_STOP_FILE ] && { echo "`date` $SCRNAME - Processing has been stopped. Exiting with exit code 0."	>> $LOGFILE ; exit 0; }

	java -jar build/acqrestproxy-*.jar --spring.config.location=./build/config/acqrestproxy.properties
	
	echo "`date` $SCRNAME - INSTANCE exited with code: $?" >> $LOGFILE
done
