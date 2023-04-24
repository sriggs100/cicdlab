#!/usr/bin/bash

# MIT License
# 
# Copyright (c) 2022 Sergio Andres Penen
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

PREFIX_DIR=~/cicdlab

ENVIRONMENT_STOP_FILE=/tmp/ENV_STOPPED

OUTPUT_LOG_FILE=/var/log/acq/acqsimul_scripts.log


SCRNAME=`basename $0`

echo "`date` $SCRNAME - EXECUTING" >> $OUTPUT_LOG_FILE

is_already_running()
{
	PROCS=`ps waux |grep cicdlab | grep -E "acqrestproxy|acqsimul|acqcsproxy" | grep -v -E "tail|grep|start_acqsimul.sh" | wc -l`
	
	if [ $PROCS -ne 0 ]
	then
		return 0
	fi	
	
	return 1
}

if is_already_running
then
	echo "`date` $SCRNAME - ERROR!! Some of the tasks are already running" >> $OUTPUT_LOG_FILE
	
	exit 1
fi


rm $ENVIRONMENT_STOP_FILE

nohup ${PREFIX_DIR}/build/scripts/restproxy_proc.sh >> $OUTPUT_LOG_FILE 2>&1 &
sleep 1
nohup ${PREFIX_DIR}/build/scripts/acqsimul_proc.sh 9090 >> $OUTPUT_LOG_FILE 2>&1 &
sleep 10
nohup ${PREFIX_DIR}/build/scripts/acqsimul_proc.sh 9091 >> $OUTPUT_LOG_FILE 2>&1 &
sleep 10
nohup ${PREFIX_DIR}/build/scripts/acqsimul_proc.sh 9092 >> $OUTPUT_LOG_FILE 2>&1 &
sleep 10
nohup ${PREFIX_DIR}/build/scripts/acqsimul_proc.sh 9093 >> $OUTPUT_LOG_FILE 2>&1 &
sleep 10
nohup ${PREFIX_DIR}/build/scripts/csproxy_proc.sh >> $OUTPUT_LOG_FILE 2>&1 &


# Give enough time for the process to initialize
sleep 10


echo "`date` $SCRNAME - FINISHED" >> $OUTPUT_LOG_FILE
