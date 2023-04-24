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



. ${SCRIPTS_DIR}/funcs.sh
. ${SCRIPTS_DIR}/db_funcs.sh



# Configure environment


OUTPUT_DIR_PREFIX=./out/test2_dba
export OUTPUT_LOG_FILE=${OUTPUT_DIR_PREFIX}/test_case2_DBA.log


create_output_dirs $OUTPUT_DIR_PREFIX


echo -e "Starting case 2 using DBA procedure on `date`\n" >> $OUTPUT_LOG_FILE

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

echo -e "\nStarting Card Scheme simulators on `date`\n" >> ${OUTPUT_LOG_FILE}

killall_simulators



zcat build/transactionResponses_file*.csv.gz | java -Xmx2G -jar  build/cssimul-0.0.1-SNAPSHOT.jar 0 4800 &
CSSIMUL_INSTANCE1_PID=$!

zcat build/transactionResponses_file*.csv.gz | java -Xmx2G -jar  build/cssimul-0.0.1-SNAPSHOT.jar 1 4900 &
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

echo -e "\nStarting Terminals simulators on `date`\n" >> ${OUTPUT_LOG_FILE}

gunzip -c ./build/transactions_file[13].csv.gz | java -Xmx2G -jar build/termsimul-*.jar - $OUTPUT_DIR_PREFIX 1 $TERMINAL_SIMULATOR_TPS $TERMINAL_SIMULATOR_TRANSACTIONS_LIMIT &
TERMSIMUL_INSTANCE1_PID=$!

gunzip -c ./build/transactions_file[24].csv.gz | java -Xmx2G -jar build/termsimul-*.jar - $OUTPUT_DIR_PREFIX 2 $TERMINAL_SIMULATOR_TPS $TERMINAL_SIMULATOR_TRANSACTIONS_LIMIT &
TERMSIMUL_INSTANCE2_PID=$!





echo -e "\nSleeping 30 secs `date`\n" >> ${OUTPUT_LOG_FILE}
sleep 30




#
# 1.- Create a new column transaction_emv_data.application_transaction_counter varchar(4)
#

echo -e "\nAbout to create new column on transaction_emv_data table `date`\n" >> ${OUTPUT_LOG_FILE}
mysql -vv experiment -e 'ALTER TABLE transaction_emv_data ADD COLUMN application_transaction_counter VARCHAR(4) DEFAULT NULL, ALGORITHM=INPLACE, LOCK=NONE;' >> ${OUTPUT_LOG_FILE} 2>&1
RETCODE=$?
echo -e "Execution returned exit code $RETCODE on `date`\n" >> ${OUTPUT_LOG_FILE}
[ $RETCODE -ne 0 ] && exit 15






#
# 2.- Create triggers on the transaction_log table to update the new table column on transaction_emv_data
#
# 3.- Create a stored procedure to copy the data to the new table column
#

echo -e "\nAbout to create database Test case 2 objects on `date`\n" >> ${OUTPUT_LOG_FILE}
mysql -vv experiment >> ${OUTPUT_LOG_FILE} 2>&1 < ${SCRIPTS_DIR}/TestCase2DBA_CreateObjects1.sql
RETCODE=$?
echo -e "Create database Test case 2 objects returned exit code $RETCODE on `date`\n" >> ${OUTPUT_LOG_FILE}
[ $RETCODE -ne 0 ] && exit 12




#
# 4.- Execute the stored procedure several times until it informs that no updates have been performed
#

echo -e "\nAbout to execute procedure on `date`\n" >> ${OUTPUT_LOG_FILE}
mysql -vv experiment -e 'SET SESSION wait_timeout=50000; CALL sp_copy_to_transaction_emv_data_atc();' >> ${OUTPUT_LOG_FILE} 2>&1
RETCODE=$?
echo -e "Procedure execution returned exit code $RETCODE on `date`\n" >> ${OUTPUT_LOG_FILE}
[ $RETCODE -ne 0 ] && exit 17







echo -e "\nSleeping 30 secs `date`\n" >> ${OUTPUT_LOG_FILE}
sleep 30


#
# 5.- Inform the development team that the new table layout is ready
# 
# Redeploy the application with support for the new database layout
#

# Start deployment
echo -e "\nAbout to restart Acquirer Simulator workers (acqsimul-db2.jar) on `date`\n" >> ${OUTPUT_LOG_FILE}

reset_acqsimul_db_config acqsimul-db2.jar

restart_acqsimul_workers



echo -e "\nSleeping 20 secs `date`\n" >> ${OUTPUT_LOG_FILE}
sleep 20





#
# 6.- As soon as the application is ready for the new layout, drop the triggers and remove transaction_log.application_transaction_counter column
#



echo -e "\nAbout to remove triggers from the legacy table and constraints on `date`\n" >> ${OUTPUT_LOG_FILE}
mysql -vv experiment -e 'DROP TRIGGER transaction_log_update_emv_data_atc_AFTER_INSERT;' >> ${OUTPUT_LOG_FILE} 2>&1
RETCODE1=$?

mysql -vv experiment -e 'DROP TRIGGER transaction_log_update_emv_data_atc_AFTER_UPDATE;' >> ${OUTPUT_LOG_FILE} 2>&1
RETCODE2=$?
echo -e "Process returned exit codes $RETCODE1 / $RETCODE2 on `date`\n" >> ${OUTPUT_LOG_FILE}
[ $RETCODE1 -ne 0 -o $RETCODE2 -ne 0 ] && exit 18



echo -e "\nSleeping 20 secs `date`\n" >> ${OUTPUT_LOG_FILE}
sleep 20




#
# Database content validation
#


echo -e "\nAbout to validate database contents on `date`\n" >> ${OUTPUT_LOG_FILE}
mysql -vv experiment -e 'SET SESSION TRANSACTION READ ONLY; CALL sp_verify_contents_transaction_emv_data_atc;' > /tmp/DB_VALIDATION_QUERY_OUTPUT
RETCODE=$?
echo -e "validate database contents query returned exit code $RETCODE on `date`\n" >> ${OUTPUT_LOG_FILE}
[ $RETCODE -ne 0 ] && exit 23





# Parse /tmp/DB_VALIDATION_QUERY_OUTPUT and validate the results

if grep "DIFFROWS=0$" /tmp/DB_VALIDATION_QUERY_OUTPUT >/dev/null
then  
	echo -e "Database contents successfully validated: There're no inconsistencies on `date`\n" >> ${OUTPUT_LOG_FILE}
else
	echo -e "Database contents are NOT consistent. Test failed. For details check /tmp/DB_VALIDATION_QUERY_OUTPUT / `date`\n" >> ${OUTPUT_LOG_FILE}
	exit 24
fi






#
# Legacy column removal. It is necessary to copy the table to a new table with the new layout since the  
# downtime caused by ALTER TABLE transaction_log DROP COLUMN application_transaction_counter, ALGORITHM=INPLACE, LOCK=NONE; 
# command is unacceptable
#







#echo -e "\nAbout to remove the legacy column from transaction_log table on `date`\n" >> ${OUTPUT_LOG_FILE}
#mysql -vv experiment -e 'ALTER TABLE transaction_log DROP COLUMN application_transaction_counter, ALGORITHM=INPLACE, LOCK=NONE;' >> ${OUTPUT_LOG_FILE} 2>&1
#RETCODE=$?
#echo -e "Legacy column removal returned exit code $RETCODE on `date`\n" >> ${OUTPUT_LOG_FILE}
#[ $RETCODE -ne 0 ] && exit 25




echo -e "\nSleeping 30 secs `date`\n" >> ${OUTPUT_LOG_FILE}
sleep 30



# The following is just to make the test execution faster
echo -e "Getting records count..." >> ${OUTPUT_LOG_FILE}
RECORDS_QTY_START=`mysql -vv experiment -e 'SELECT MAX(id) FROM transaction_log;' | tail -4 | head -1`
echo -e "max(id) in transaction_log: $RECORDS_QTY_START" >> ${OUTPUT_LOG_FILE}




echo -e "\nAbout to create database Test case 2 objects #1 on `date`\n" >> ${OUTPUT_LOG_FILE}
mysql -vv experiment >> ${OUTPUT_LOG_FILE} < ${SCRIPTS_DIR}/TestCase2DBA_CreateObjects2.sql
RETCODE=$?
echo -e "Create database Test case 2 objects #2 returned exit code $RETCODE on `date`\n" >> ${OUTPUT_LOG_FILE}
[ $RETCODE -ne 0 ] && exit 25






echo -e "\nAbout to execute procedure (3 procedures in parallel) on `date`\n" >> ${OUTPUT_LOG_FILE}


QTY_PER_EXECUTION=$((${RECORDS_QTY_START}/3))

CMD="CALL sp_copy_to_transaction_log_new( 0, ${QTY_PER_EXECUTION}, 30000, 0 );"
echo -e "\nAbout to execute SQL command: $CMD" >> ${OUTPUT_LOG_FILE}
mysql -vv experiment -e "$CMD" >> ${OUTPUT_LOG_FILE} &
PID1=$!

sleep 30

CMD="CALL sp_copy_to_transaction_log_new( ${QTY_PER_EXECUTION}, $((${QTY_PER_EXECUTION}*2)), 30000, 0 );"
echo -e "\nAbout to execute SQL command: $CMD" >> ${OUTPUT_LOG_FILE}
mysql -vv experiment -e "$CMD" >> ${OUTPUT_LOG_FILE} &
PID2=$!

sleep 30

CMD="CALL sp_copy_to_transaction_log_new( $((${QTY_PER_EXECUTION}*2)), ${RECORDS_QTY_START}, 30000, 0 );"
echo -e "\nAbout to execute SQL command: $CMD" >> ${OUTPUT_LOG_FILE}
mysql -vv experiment -e "$CMD" >> ${OUTPUT_LOG_FILE} &
PID3=$!


wait $PID1
RETCODE1=$?

wait $PID2
RETCODE2=$?

wait $PID3
RETCODE3=$?

echo -e "Procedure executions returned exit code $RETCODE1 / $RETCODE2 / $RETCODE3 on `date`\n" >> ${OUTPUT_LOG_FILE}
[ $RETCODE1 -ne 0 -o $RETCODE2 -ne 0 -o $RETCODE3 -ne 0 ] && exit 26




echo -e "\nAbout to create indexes (1) on `date`\n" >> ${OUTPUT_LOG_FILE}
mysql -vv experiment -e 'CREATE INDEX cardSchemeIdx ON transaction_log_new (card_scheme) ALGORITHM=INPLACE LOCK=NONE;' >> ${OUTPUT_LOG_FILE}
RETCODE1=$?

echo -e "\nSleeping 10 secs `date`\n" >> ${OUTPUT_LOG_FILE}
sleep 10

echo -e "\nAbout to create indexes (2) on `date`\n" >> ${OUTPUT_LOG_FILE}


mysql -vv experiment -e 'CREATE INDEX functionCodeIdx ON transaction_log_new (function_code) ALGORITHM=INPLACE LOCK=NONE;' >> ${OUTPUT_LOG_FILE}
RETCODE2=$?

echo -e "\nSleeping 10 secs `date`\n" >> ${OUTPUT_LOG_FILE}
sleep 10

echo -e "\nAbout to create indexes (3) on `date`\n" >> ${OUTPUT_LOG_FILE}

mysql -vv experiment -e 'CREATE INDEX utcCaptureDateTimeIdx ON transaction_log_new (utc_capture_date_time) ALGORITHM=INPLACE LOCK=NONE;' >> ${OUTPUT_LOG_FILE}
RETCODE3=$?


echo -e "Indexes creation returned exit code  $RETCODE1 / $RETCODE2 / $RETCODE3 on `date`\n" >> ${OUTPUT_LOG_FILE}
[ $RETCODE1 -ne 0 -o $RETCODE2 -ne 0 -o $RETCODE3 -ne 0 ] && exit 27



echo -e "\nSleeping 10 secs `date`\n" >> ${OUTPUT_LOG_FILE}
sleep 10


echo -e "\nAbout to create unique constraints on `date`\n" >> ${OUTPUT_LOG_FILE}
mysql -vv experiment -e 'SET @@unique_checks=0; ALTER TABLE transaction_log_new ADD CONSTRAINT UniqueMerchantTerminalStan UNIQUE (merchant_id, terminal_id, stan), ALGORITHM=INPLACE, LOCK=NONE; SET @@unique_checks=1;' >> ${OUTPUT_LOG_FILE}
RETCODE=$?
echo -e "Unique constraints creation returned exit code $RETCODE on `date`\n" >> ${OUTPUT_LOG_FILE}
[ $RETCODE -ne 0 ] && exit 28


echo -e "\nSleeping 10 secs `date`\n" >> ${OUTPUT_LOG_FILE}
sleep 10


echo -e "\nAbout to create foreign key constraint on `date`\n" >> ${OUTPUT_LOG_FILE}
mysql -vv experiment -e 'SET @@foreign_key_checks=0; ALTER TABLE transaction_log_new ADD CONSTRAINT FKtb0lwheccb9uailspbkittqha_1_new FOREIGN KEY (transaction_emv_data_id) REFERENCES transaction_emv_data (id); SET @@foreign_key_checks=1;' >> ${OUTPUT_LOG_FILE}
RETCODE=$?
echo -e "Foreign key constraint  creation returned exit code $RETCODE on `date`\n" >> ${OUTPUT_LOG_FILE}
[ $RETCODE -ne 0 ] && exit 29




echo -e "\nSleeping 60 secs `date`\n" >> ${OUTPUT_LOG_FILE}
sleep 60




#
# Now we need to copy the most recent data that has been inserted in the last few hours
#


echo -e "Getting records count..." >> ${OUTPUT_LOG_FILE}
RECORDS_MAX_ID=`mysql -vv experiment -e 'SELECT MAX(id) FROM transaction_log;' | tail -4 | head -1`

echo -e "max(id) in transaction_log: $RECORDS_MAX_ID" >> ${OUTPUT_LOG_FILE}



CMD="CALL sp_copy_to_transaction_log_new( ${RECORDS_QTY_START}, $((${RECORDS_MAX_ID}+1)), 10000, 0 );"
echo -e "\nAbout to execute SQL command: $CMD" >> ${OUTPUT_LOG_FILE}

mysql -vv experiment -e "$CMD" >> ${OUTPUT_LOG_FILE} 
RETCODE=$?

echo -e "Procedure execution returned exit code $RETCODE on `date`\n" >> ${OUTPUT_LOG_FILE}
[ $RETCODE -ne 0 ] && exit 30



#
# At this point we have the new table created with all the indexes and constraints up to id = RECORDS_MAX_ID
# We need to create the insert and update triggers to keep the information on both tables synchronized while the remaining records are being copied
#


#
# Test case 2 DBA procedure #3.
#

echo -e "\nAbout to create database Test case 2 objects #3 on `date`\n" >> ${OUTPUT_LOG_FILE}
mysql -vv experiment >> ${OUTPUT_LOG_FILE} < ${SCRIPTS_DIR}/TestCase2DBA_CreateObjects3.sql
RETCODE=$?
echo -e "Create database Test case 2 objects #3 returned exit code $RETCODE on `date`\n" >> ${OUTPUT_LOG_FILE}
[ $RETCODE -ne 0 ] && exit 31



echo -e "\nSleeping 60 secs `date`\n" >> ${OUTPUT_LOG_FILE}
sleep 60




#
# Now we need to carefully (using very small batches) copy the most recent data that has been inserted in the last few minutes
#

PREVIOUS_MAX=$RECORDS_MAX_ID

echo -e "Getting records count..." >> ${OUTPUT_LOG_FILE}
RECORDS_MAX_ID=`mysql -vv experiment -e 'SELECT MAX(id) FROM transaction_log;' | tail -4 | head -1`

echo -e "max(id) in transaction_log: $RECORDS_MAX_ID" >> ${OUTPUT_LOG_FILE}




CMD="CALL sp_copy_to_transaction_log_new( ${PREVIOUS_MAX}, $((${RECORDS_MAX_ID}+1)), 40, 1 );"
echo -e "\nAbout to execute SQL command: $CMD" >> ${OUTPUT_LOG_FILE}

mysql -vv experiment -e "$CMD" >> ${OUTPUT_LOG_FILE} 
RETCODE=$?

echo -e "Procedure execution returned exit code $RETCODE on `date`\n" >> ${OUTPUT_LOG_FILE}
[ $RETCODE -ne 0 ] && exit 32



echo -e "\nSleeping 60 secs `date`\n" >> ${OUTPUT_LOG_FILE}
sleep 60



echo -e "\nAbout to remove foreign keys from the legacy table as well as constraints on `date`\n" >> ${OUTPUT_LOG_FILE}

mysql -vv experiment -e 'ALTER TABLE transaction_log DROP FOREIGN KEY FKtb0lwheccb9uailspbkittqha, ALGORITHM=INPLACE, LOCK=NONE;' >> ${OUTPUT_LOG_FILE}
RETCODE1=$?
echo -e "Process returned exit codes $RETCODE1 on `date`\n" >> ${OUTPUT_LOG_FILE}
[ $RETCODE1 -ne 0 ] && exit 33



echo -e "\nSleeping 30 secs `date`\n" >> ${OUTPUT_LOG_FILE}
sleep 30



# Rename database table while redeploying the new application to support the new layout

# Start deployment
echo -e "\nAbout to restart Acquirer Simulator workers (acqsimul-db2.jar) on `date`\n" >> ${OUTPUT_LOG_FILE}

reset_acqsimul_db_config acqsimul-db2.jar

restart_acqsimul_workers



echo -e "\nSleeping 10 secs `date`\n" >> ${OUTPUT_LOG_FILE}
sleep 10



echo -e "\nAbout to rename the table on `date`\n" >> ${OUTPUT_LOG_FILE}

mysql -vv experiment -e 'LOCK TABLES transaction_log WRITE, transaction_log_new WRITE; RENAME TABLE transaction_log TO transaction_log_OLD, transaction_log_new TO transaction_log; UNLOCK TABLES;' >> ${OUTPUT_LOG_FILE}
RETCODE1=$?

echo -e "Table renaming returned exit codes $RETCODE1 on `date`\n" >> ${OUTPUT_LOG_FILE}
[ $RETCODE1 -ne 0 ] && exit 34




echo -e "\nAbout to remove triggers from the legacy table as well as constraints on `date`\n" >> ${OUTPUT_LOG_FILE}

mysql -vv experiment -e 'DROP TRIGGER IF EXISTS transaction_log_AFTER_INSERT;' >> ${OUTPUT_LOG_FILE}
RETCODE2=$?
mysql -vv experiment -e 'DROP TRIGGER IF EXISTS transaction_log_AFTER_UPDATE;' >> ${OUTPUT_LOG_FILE}
RETCODE3=$?
mysql -vv experiment -e 'DROP PROCEDURE IF EXISTS sp_insert_to_new_table_from_trigger;' >> ${OUTPUT_LOG_FILE}
RETCODE4=$?
mysql -vv experiment -e 'DROP PROCEDURE IF EXISTS sp_update_new_table_from_trigger;' >> ${OUTPUT_LOG_FILE}
RETCODE5=$?
mysql -vv experiment -e 'DROP PROCEDURE IF EXISTS sp_copy_to_transaction_log_new;' >> ${OUTPUT_LOG_FILE}
RETCODE6=$?
echo -e "Process returned exit codes $RETCODE2 / $RETCODE3 / $RETCODE4 / $RETCODE5 / $RETCODE6 on `date`\n" >> ${OUTPUT_LOG_FILE}
[ $RETCODE2 -ne 0 -o $RETCODE3 -ne 0 -o $RETCODE4 -ne 0 -o $RETCODE5 -ne 0 -o $RETCODE6 -ne 0 ] && exit 35





echo -e "\nAbout to drop the legacy table on `date`\n" >> ${OUTPUT_LOG_FILE}
mysql -vv experiment -e 'DROP TABLE transaction_log_OLD;' >> ${OUTPUT_LOG_FILE}
RETCODE=$?
echo -e "Table dropping returned exit code $RETCODE on `date`\n" >> ${OUTPUT_LOG_FILE}
[ $RETCODE -ne 0 ] && exit 36





#
# Check whether simulators are still running
#

if ! are_terminals_simulators_running
then 
	echo -e "Error! At least one of the terminal simulators are not running anymore `date`\n" >> ${OUTPUT_LOG_FILE}
	exit 37
fi





#
# Wait for simulators to finish
#

echo -e "\nWaiting for simulators to finish on `date`\n" >> ${OUTPUT_LOG_FILE}

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

get_erm ${OUTPUT_DIR_PREFIX} ResultingERM

get_transactions_report ${OUTPUT_DIR_PREFIX} AFTER_RUN


${SCRIPTS_DIR}/get_missing_transactions_report.sh ${OUTPUT_DIR_PREFIX}


backup_database ${OUTPUT_DIR_PREFIX} test2_dba


echo -e "\nTest case 2 DBA execution finished with exit code $TEST_CASE_RETCODE on `date`\n" >> ${OUTPUT_LOG_FILE}

exit $TEST_CASE_RETCODE




