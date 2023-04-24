#!/usr/bin/bash

ENVIRONMENT_STOP_FILE=/tmp/ENV_STOPPED

LOGFILE=/var/log/acq/acqsimul.log
SCRNAME=`basename $0`

SERVER_PORT=$1
ACQSIMUL_OBJECT_NAME=./build/acqsimul-current.jar

while true
do 
	echo "`date` $SCRNAME - STARTING INSTANCE"	>> $LOGFILE

	[ -f $ENVIRONMENT_STOP_FILE ] && { echo "`date` $SCRNAME - Processing has been stopped. Exiting with exit code 0."	>> $LOGFILE ; exit 0; }
	
	
	ACQSIMUL_OBJECT_NAME=`cat /tmp/CURRENT_ACQSIMUL_OBJECT_NAME`
	
	echo "`date` $SCRNAME - About to start jar $ACQSIMUL_OBJECT_NAME"	>> $LOGFILE
	
	java -Dserver.port=${SERVER_PORT} -jar ${ACQSIMUL_OBJECT_NAME} --spring.config.location=./build/config/acqsimul.properties
	
	echo "`date` $SCRNAME - INSTANCE exited with code: $?" >> $LOGFILE
done
