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



# This script is responsible to run all the test cases for the experiment
# Depending on the file name, that is the outcome of the AWS pipeline, it will execute 
# either a small test or the complete execution.
# The execution type is received as $1 parameter
# It is possible to limit the execution of this script to a single test. In order to do that a file must be created under /tmp with the following format /tmp/SINGLETEST-DEVOPS-1 or /tmp/SINGLETEST-DBA-1
# The file names are as follows:

export TEST_FILE_NAME=CICDLabTest.zip
export PROD_FILE_NAME=CICDLabProd.zip

SCRNAME=`basename $0`

SCRIPTS_DIR=~/cicdlab/build/scripts

. ${SCRIPTS_DIR}/funcs.sh

export EXECUTION_TYPE_TEST="TEST"
export EXECUTION_TYPE_PROD="PROD"


ENVIRONMENT_LOCK_FILE=/tmp/ENV_LOCKED

if [ "$#" -ne 1 ]
then
    echo "$SCRNAME - ERROR. Illegal number of parameters / Probably the execution type is missing"
	
	exit 1
fi



export EXECUTION_TYPE=$1


# Check that the input file exists
if [ "$EXECUTION_TYPE" = "$EXECUTION_TYPE_TEST" -a ! -f $TEST_FILE_NAME ]
then
	echo "Error. There's no input file named $TEST_FILE_NAME or $PROD_FILE_NAME"
	exit 2
fi


[ ! -f $ENVIRONMENT_LOCK_FILE ] && { echo "`date` $SCRNAME - Environment not locked.. Not processing"; exit 12; }


#
# Prepare environment
#

# Save any previous results
HASH=`date | md5sum | cut -d " " -f 1`
mv ./out ./out-$HASH

mkdir ./out

OUTPUT_LOG_FILE=${PWD}/out/execution.log





#
# Configuration parameters for test type executions
#

export TERMINAL_SIMULATOR_TRANSACTIONS_LIMIT=""
export TERMINAL_SIMULATOR_TPS=""

if [ "$EXECUTION_TYPE" = "$EXECUTION_TYPE_TEST" ]
then
	# The following values are "per instance"

	TERMINAL_SIMULATOR_TPS=22
	TERMINAL_SIMULATOR_TRANSACTIONS_LIMIT=40000
else
	# Production
	
	TERMINAL_SIMULATOR_TPS=`grep TERMINAL_SIMULATOR_TPS build/config/env.cfg | grep -v "^#" | awk -F: '{ print $2 }'`
	TERMINAL_SIMULATOR_TRANSACTIONS_LIMIT=`grep TERMINAL_SIMULATOR_TRANSACTIONS_LIMIT build/config/env.cfg | grep -v "^#" | awk -F: '{ print $2 }'`
fi




# Configure environment

export DATABASELINE0_FILE
mkdir -p ~/cicdlab/config/test_env 2>/dev/null
mkdir -p ~/cicdlab/config/production_env 2>/dev/null
if [ $EXECUTION_TYPE = $EXECUTION_TYPE_TEST ]
then
	cp -p ~/cicdlab/build/config/my.cnf ~/.my.cnf
	cp -p ~/cicdlab/build/config/cicdlab-test-databaseline0.sql.gz ~/cicdlab/config/test_env
	DATABASELINE0_FILE=~/cicdlab/config/test_env/cicdlab-test-databaseline0.sql.gz
else
	cp -p ~/cicdlab/build/config/my.cnf ~/.my.cnf
	
	# The following file is HUGE so it has been already copied to the destination directory
	#cp -p ~/cicdlab/config/test_env/cicdlab-test-databaseline0.sql.gz ~/cicdlab/config/test_env
	DATABASELINE0_FILE=~/cicdlab/config/production_env/cicdlab-prod-databaseline0.sql.gz
	
fi



is_test_must_be_executed()
{
	TEST_TYPE=$1
	TEST_NUMBER=$2
	
	FILES=`ls -1 /tmp/SINGLETEST-* 2>/dev/null |wc -l`
	
	if [ $FILES -ne 0 ]
	then
		if [ -f /tmp/SINGLETEST-${TEST_TYPE}-${TEST_NUMBER} ]
		then
			return 0
		fi
		
		# Test must not be exeuted
		return 1
	fi

	# All tests must be executed
	return 0 
}


#
# Start execution
#

echo "Starting execution on `date` with the following parameters: " >> $OUTPUT_LOG_FILE
echo "EXECUTION_TYPE: $EXECUTION_TYPE" >> $OUTPUT_LOG_FILE
echo "TEST_FILE_NAME: $TEST_FILE_NAME" >> $OUTPUT_LOG_FILE
echo "TERMINAL_SIMULATOR_TRANSACTIONS_LIMIT: $TERMINAL_SIMULATOR_TRANSACTIONS_LIMIT" >> $OUTPUT_LOG_FILE
echo "TERMINAL_SIMULATOR_TPS: $TERMINAL_SIMULATOR_TPS" >> $OUTPUT_LOG_FILE


# First, a test case 0 which consist of processing all the transactions without any deployments
# The idea behind this is that a perfect zero-downtime deployment would be as close as possible 
# to the response time and captured transactions totals obtained in this test case


if is_test_must_be_executed DBA 0 -o is_test_must_be_executed DEVOPS 0
then
	echo -e "\nStarting Test case 0 execution on `date`\n" >> $OUTPUT_LOG_FILE
	${SCRIPTS_DIR}/test_case0.sh
	RETCODE=$?
			
	MSG="\nTest case 0 execution finished with exit code $RETCODE on `date`\n"
	[ "$EXECUTION_TYPE" = "$EXECUTION_TYPE_PROD" ] && aws sns publish --target-arn arn:aws:sns:eu-west-2:669121439246:cicdlab --message "$MSG"
	echo -e "$MSG" >> $OUTPUT_LOG_FILE


	stop_monitoring
	killall_simulators
	collect_log_files out/test0

	[ $RETCODE -ne 0 ] && exit 20

else
	echo -e "\nTest case 0 execution DISABLED on `date`\n" >> $OUTPUT_LOG_FILE
fi


# Test case 1 using DBA procedure


if is_test_must_be_executed DBA 1
then
	echo -e "\nStarting execution of Test case 1 using DBA procedure on `date`\n" >> $OUTPUT_LOG_FILE
	${SCRIPTS_DIR}/test_case1_dba.sh
	RETCODE=$?
		
	MSG="\nTest case 1 using DBA procedure finished with exit code $RETCODE on `date`\n"
	[ "$EXECUTION_TYPE" = "$EXECUTION_TYPE_PROD" ] && aws sns publish --target-arn arn:aws:sns:eu-west-2:669121439246:cicdlab --message "$MSG"
	echo -e "$MSG" >> $OUTPUT_LOG_FILE


	stop_monitoring
	killall_simulators
	collect_log_files out/test1_dba

	[ $RETCODE -ne 0 ] && exit 21
else
	echo -e "\nTest case 1 using DBA procedure DISABLED on `date`\n" >> $OUTPUT_LOG_FILE
fi



# Test case 1 using DevOps procedure

if is_test_must_be_executed DEVOPS 1
then
	echo -e "\nStarting execution of Test case 1 using DevOps procedure on `date`\n" >> $OUTPUT_LOG_FILE
	${SCRIPTS_DIR}/test_case1_devops.sh
	RETCODE=$?
	
	MSG="\nTest case 1 using DevOps procedure finished with exit code $RETCODE on `date`\n"
	[ "$EXECUTION_TYPE" = "$EXECUTION_TYPE_PROD" ] && aws sns publish --target-arn arn:aws:sns:eu-west-2:669121439246:cicdlab --message "$MSG"
	echo -e "$MSG" >> $OUTPUT_LOG_FILE


	stop_monitoring
	killall_simulators
	collect_log_files out/test1_devops

	[ $RETCODE -ne 0 ] && exit 22
else
	echo -e "\nTest case 1 using DevOps procedure DISABLED on `date`\n" >> $OUTPUT_LOG_FILE
fi



# Test case 2 using DBA procedure

if is_test_must_be_executed DBA 2
then
	echo -e "\nStarting execution of Test case 2 using DBA procedure on `date`\n" >> $OUTPUT_LOG_FILE
	${SCRIPTS_DIR}/test_case2_dba.sh
	RETCODE=$?
	
	MSG="\nTest case 2 using DBA procedure finished with exit code $RETCODE on `date`\n"
	[ "$EXECUTION_TYPE" = "$EXECUTION_TYPE_PROD" ] && aws sns publish --target-arn arn:aws:sns:eu-west-2:669121439246:cicdlab --message "$MSG"
	echo -e "$MSG" >> $OUTPUT_LOG_FILE


	stop_monitoring
	killall_simulators
	collect_log_files out/test2_dba
	
	[ $RETCODE -ne 0 ] && exit 23
else
	echo -e "\nTest case 2 using DBA procedure DISABLED on `date`\n" >> $OUTPUT_LOG_FILE
fi



# Test case 2 using DevOps procedure

if is_test_must_be_executed DEVOPS 2
then
	echo -e "\nStarting execution of Test case 2 using DevOps procedure on `date`\n" >> $OUTPUT_LOG_FILE
	${SCRIPTS_DIR}/test_case2_devops.sh
	RETCODE=$?

	MSG="\nTest case 2 using DevOps procedure finished with exit code $RETCODE on `date`\n"
	[ "$EXECUTION_TYPE" = "$EXECUTION_TYPE_PROD" ] && aws sns publish --target-arn arn:aws:sns:eu-west-2:669121439246:cicdlab --message "$MSG"
	echo -e "$MSG" >> $OUTPUT_LOG_FILE


	stop_monitoring
	killall_simulators
	collect_log_files out/test2_devops
	
	[ $RETCODE -ne 0 ] && exit 24
else
	echo -e "\nTest case 2 using DEVOPS procedure DISABLED on `date`\n" >> $OUTPUT_LOG_FILE
fi




# Test case 3 using DBA procedure

if is_test_must_be_executed DBA 3
then
	echo -e "\nStarting execution of Test case 3 using DBA procedure on `date`\n" >> $OUTPUT_LOG_FILE
	${SCRIPTS_DIR}/test_case3_dba.sh
	RETCODE=$?

	MSG="\nTest case 3 using DBA procedure finished with exit code $RETCODE on `date`\n"
	[ "$EXECUTION_TYPE" = "$EXECUTION_TYPE_PROD" ] && aws sns publish --target-arn arn:aws:sns:eu-west-2:669121439246:cicdlab --message "$MSG"
	echo -e "$MSG" >> $OUTPUT_LOG_FILE
	
	
	stop_monitoring
	killall_simulators
	collect_log_files out/test3_dba
	
	[ $RETCODE -ne 0 ] && exit 25
else
	echo -e "\nTest case 3 using DBA procedure DISABLED on `date`\n" >> $OUTPUT_LOG_FILE
fi



# Test case 3 using DevOps procedure
if is_test_must_be_executed DEVOPS 3
then
	echo -e "\nStarting execution of Test case 3 using DevOps procedure on `date`\n" >> $OUTPUT_LOG_FILE
	${SCRIPTS_DIR}/test_case3_devops.sh
	RETCODE=$?
	
	MSG="\nTest case 3 using DevOps procedure finished with exit code $RETCODE on `date`\n"
	[ "$EXECUTION_TYPE" = "$EXECUTION_TYPE_PROD" ] && aws sns publish --target-arn arn:aws:sns:eu-west-2:669121439246:cicdlab --message "$MSG"
	echo -e "$MSG" >> $OUTPUT_LOG_FILE

	stop_monitoring
	killall_simulators
	collect_log_files out/test3_devops
	
	[ $RETCODE -ne 0 ] && exit 26
else
	echo -e "\nTest case 3 using DEVOPS procedure DISABLED on `date`\n" >> $OUTPUT_LOG_FILE
fi


MSG="\nExecution finished on `date`"
[ "$EXECUTION_TYPE" = "$EXECUTION_TYPE_PROD" ] && aws sns publish --target-arn arn:aws:sns:eu-west-2:669121439246:cicdlab --message "$MSG"
echo -e "$MSG" >> $OUTPUT_LOG_FILE
exit 0
