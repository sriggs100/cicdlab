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

SCRIPTS_DIR=~/cicdlab/build/scripts


drop_schema()
{
	echo -e "\nAbout to drop database schema on `date`\n" >> ${OUTPUT_LOG_FILE}

	mysql -vv -e 'DROP DATABASE IF EXISTS experiment;' >> ${OUTPUT_LOG_FILE}
	RETCODE=$?

	echo -e "Drop database schema finished with exit code $RETCODE on `date`\n" >> ${OUTPUT_LOG_FILE}
	
	return $RETCODE
}


create_schema()
{
	echo -e "\nAbout to create database schema on `date`\n" >> ${OUTPUT_LOG_FILE}

	mysql -vv -e 'CREATE DATABASE experiment CHARACTER SET utf8mb4;' >> ${OUTPUT_LOG_FILE}
	RETCODE=$?
	

	echo -e "Create database schema finished with exit code $RETCODE on `date`\n" >> ${OUTPUT_LOG_FILE}
		
	return $RETCODE
}


create_schema_objects()
{
	echo -e "\nAbout to create database schema objects on `date`\n" >> ${OUTPUT_LOG_FILE}

	mysql -vv experiment >> ${OUTPUT_LOG_FILE} < ${SCRIPTS_DIR}/CreateSchema.sql
	RETCODE=$?
	
	mysql -vv experiment -e 'ALTER TABLE transaction_log ROW_FORMAT=COMPRESSED;' >> ${OUTPUT_LOG_FILE}
	RETCODE=$((${RETCODE}+$?))

	echo -e "Create database schema objects finished with exit code $RETCODE on `date`\n" >> ${OUTPUT_LOG_FILE}
	
	return $RETCODE
}


import_databaseline0()
{
	echo -e "\nAbout to import data baseline 0 file \"$1\" on `date`\n" >> ${OUTPUT_LOG_FILE}
	
	if [ `basename $1` = "cicdlab-prod-databaseline0.sql.gz" ]
	then 
		# This is production test which is a huge SQL file that use to take more than nine hour of processing time.
		# In order to save time, it is better to run the following script in the remote machine which will replace all db files in the filesystem. It takes less than 1/2h
		
		production_db_reset PROD
	
	elif [ `basename $1` = "cicdlab-mid-databaseline0.sql.gz" ]
	then 
		# Test with a medium size database (10M txn)
		
		production_db_reset MIDSIZE
		
	elif [ -f "$1" ]
	then
		gunzip -c "$1" | mysql -v experiment >> ${OUTPUT_LOG_FILE}
		GUNZIP_RETCODE=${PIPESTATUS[0]} MYSQL_RETCODE=${PIPESTATUS[1]}
		RETCODE=$((${GUNZIP_RETCODE}+${MYSQL_RETCODE}))

		echo -e "Import data baseline 0 finished with exit codes ${GUNZIP_RETCODE} and ${MYSQL_RETCODE} on `date`\n" >> ${OUTPUT_LOG_FILE}
		
		return $RETCODE
	else
		echo -e "ERROR, input file \"$1\" cannot be read!! on `date`\n" >> ${OUTPUT_LOG_FILE}
		
		return 1
	fi
}

production_db_reset()
{
	RESET_TYPE=$1
	ssh -p 8246 cicdlab@dbhost 'cd /home/cicdlab/cicdlab; ~/bin/reset_production_db_to_databaseline0.sh '$RESET_TYPE
}


get_transactions_report()
{
	OUT_PREFIX_DIR=$1
	REPORT_TYPE=$2
	
	echo -e "\nAbout to get transactions report from database on `date`\n" >> ${OUTPUT_LOG_FILE}
	
	mysql -vvv experiment >> ${OUTPUT_LOG_FILE} < ${SCRIPTS_DIR}/ValidateDbContent.sql >> ${OUT_PREFIX_DIR}/ValidateDbContent_${REPORT_TYPE}.out
	RETCODE=$?

	echo -e "\nTransactions report finished with exit code ${RETCODE} on `date`\n" >> ${OUTPUT_LOG_FILE}
	
	return $RETCODE
}


get_erm()
{
	OUTPUT_DIR=$1
	FILE_NAME=$2
	
	echo -e "\nAbout to get ERM from database on `date`\n" >> ${OUTPUT_LOG_FILE}
	
	mysqldump --no-tablespaces -d experiment > ${OUTPUT_DIR}/${FILE_NAME}.sql 2>> ${OUTPUT_LOG_FILE}
	RETCODE=$?

	echo -e "\nERM finished with exit code ${RETCODE} on `date`\n" >> ${OUTPUT_LOG_FILE}
	
	return $RETCODE
}


backup_database()
{
	BACKUP_DIR=$1
	FILE_NAME=$2

	echo -e "\nAbout to get a database backup on `date`\n" >> ${OUTPUT_LOG_FILE}
	
	ssh -p 8246 cicdlab@dbhost 'mysqldump --no-tablespaces experiment |gzip -9c' > ${BACKUP_DIR}/${FILE_NAME}.sql.gz 2>> ${OUTPUT_LOG_FILE}
	RETCODE=$?

	echo -e "\nBackup finished with exit code ${RETCODE} on `date`\n" >> ${OUTPUT_LOG_FILE}
	
	return $RETCODE
}


