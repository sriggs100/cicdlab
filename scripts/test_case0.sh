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

SCRIPTS_DIR=~/cicdlab/build/scripts

SCRNAME=`basename $0`

. ${SCRIPTS_DIR}/funcs.sh
. ${SCRIPTS_DIR}/db_funcs.sh



# Configure environment


OUTPUT_DIR_PREFIX=./out/test0
export OUTPUT_LOG_FILE=${OUTPUT_DIR_PREFIX}/test_case0.log


create_output_dirs $OUTPUT_DIR_PREFIX


echo -e "`date` $SCRNAME - Starting case 0 on `date`\n" >> $OUTPUT_LOG_FILE

start_monitoring


#
# Prepare the database
#

drop_schema; [ $? -ne 0 ] && exit 10
create_schema; [ $? -ne 0 ] && exit 11
create_schema_objects; [ $? -ne 0 ] && exit 12
import_databaseline0 "$DATABASELINE0_FILE"; [ $? -ne 0 ] && exit 13


get_erm ${OUTPUT_DIR_PREFIX} StartingERM

get_transactions_report ${OUTPUT_DIR_PREFIX} BEFORE_RUN



#
# Start the Card Scheme simulators
#

echo -e "\n`date` $SCRNAME - Starting Card Scheme simulators on `date`\n" >> ${OUTPUT_LOG_FILE}

killall_simulators

#ADD_JVM_OPTIONS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.local.only=true -Dcom.sun.management.jmxremote.port=5500 -Dcom.sun.management.jmxremote.rmi.port=5501 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=localhost"

zcat build/transactionResponses_file*.csv.gz | java -Xmx2G $ADD_JVM_OPTIONS -jar  build/cssimul-0.0.1-SNAPSHOT.jar 0 4800 &
CSSIMUL_INSTANCE1_PID=$!

zcat build/transactionResponses_file*.csv.gz | java -Xmx2G $ADD_JVM_OPTIONS -jar  build/cssimul-0.0.1-SNAPSHOT.jar 1 4900 &
CSSIMUL_INSTANCE2_PID=$!



echo -e "\nSleeping 30 secs `date`\n" >> ${OUTPUT_LOG_FILE}
sleep 30



#
# Start the Acquirer Simulators (remote execution)
#
echo -e "\n`date` $SCRNAME - Starting Acquirer simulators (acqsimul-db0.jar) on `date`\n" >> ${OUTPUT_LOG_FILE}

reset_acqsimul_db_config acqsimul-db0.jar
start_acqsimul



echo -e "\nSleeping 30 secs `date`\n" >> ${OUTPUT_LOG_FILE}
sleep 30



#
# Start the terminals simulators
#

echo -e "\n`date` $SCRNAME - Starting Terminals simulators on `date`\n" >> ${OUTPUT_LOG_FILE}

gunzip -c ./build/transactions_file[13].csv.gz | java -Xmx2G -jar build/termsimul-*.jar - $OUTPUT_DIR_PREFIX 1 $TERMINAL_SIMULATOR_TPS $TERMINAL_SIMULATOR_TRANSACTIONS_LIMIT &
TERMSIMUL_INSTANCE1_PID=$!

gunzip -c ./build/transactions_file[24].csv.gz | java -Xmx2G -jar build/termsimul-*.jar - $OUTPUT_DIR_PREFIX 2 $TERMINAL_SIMULATOR_TPS $TERMINAL_SIMULATOR_TRANSACTIONS_LIMIT &
TERMSIMUL_INSTANCE2_PID=$!



echo -e "\nSleeping 30 secs `date`\n" >> ${OUTPUT_LOG_FILE}
sleep 30



#
# Restart Acquirer simulators (to analyse the impact)
#
echo -e "\nAbout to restart Acquirer Simulator workers (same db layer) on `date`\n" >> ${OUTPUT_LOG_FILE}

restart_acqsimul_workers




#
# Check whether simulators are still running
#

if ! are_terminals_simulators_running
then 
	echo -e "Error! At least one of the terminal simulators are not running anymore `date`\n" >> ${OUTPUT_LOG_FILE}
	exit 23
fi




#
# Wait for simulators to finish
#

echo -e "\n`date` $SCRNAME - Waiting for simulators to finish on `date`\n" >> ${OUTPUT_LOG_FILE}

export CSSIMUL_INSTANCE1_RETCODE=999
export CSSIMUL_INSTANCE2_RETCODE=999
export TERMSIMUL_INSTANCE1_RETCODE=999
export TERMSIMUL_INSTANCE2_RETCODE=999
export ERROR_CONDITION=1

wait_for_simulators



#
# Stop the Acquirer Simulators (remote execution)
#

stop_acqsimul




#
# Analyze return codes
#

if [ $SHUTDOWN_COMMAND_SENT -ne 0 ] 
then
	if [ $CSSIMUL_INSTANCE1_RETCODE -eq 138 ]
	then
		CSSIMUL_INSTANCE1_RETCODE=0
	fi
	
	if [ $CSSIMUL_INSTANCE2_RETCODE -eq 138 ]
	then
		CSSIMUL_INSTANCE2_RETCODE=0
	fi
fi

export TEST_CASE_RETCODE

RETCODES=$((${TERMSIMUL_INSTANCE1_RETCODE}+${TERMSIMUL_INSTANCE2_RETCODE}+${CSSIMUL_INSTANCE1_RETCODE}+${CSSIMUL_INSTANCE2_RETCODE}))

if [ $ERROR_CONDITION -eq 0 -a $RETCODES -eq 0 ]
then
	echo -e "\n`date` $SCRNAME - Test case processing successfully finished\n------------------------------------------\n" >> ${OUTPUT_LOG_FILE}

	TEST_CASE_RETCODE=0
else
	echo -e "\n`date` $SCRNAME - An error occurred during the test case processing\n-------------------------------------------------\n" >> ${OUTPUT_LOG_FILE}

	TEST_CASE_RETCODE=1
fi


stop_monitoring

#
# Save the output data
#

get_transactions_report ${OUTPUT_DIR_PREFIX} AFTER_RUN


${SCRIPTS_DIR}/get_missing_transactions_report.sh ${OUTPUT_DIR_PREFIX}


echo -e "\n`date` $SCRNAME - Test case 0 execution finished with exit code $TEST_CASE_RETCODE on `date`\n" >> ${OUTPUT_LOG_FILE}

exit $TEST_CASE_RETCODE


