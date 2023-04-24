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

if [ $# -ne 1 ]
then
	echo >&2
	echo "usage: get_missing_transactions.sh <test case directory>" >&2
	echo >&2

	exit 1
fi

TEST_CASE_NAME=`basename "$1"`

TEST_CASE_FULLPATH=`realpath "$1"`

if [ ! -d "$TEST_CASE_FULLPATH/termsimul" ]
then 
	echo >&2
	echo "Invalid test case directory. Fullpath: $TEST_CASE_FULLPATH" >&2
	echo >&2

	exit 2
fi


TEMP="${TEMP:-/tmp}";

if [ ! -d "$TEMP" ]
then 
	echo >&2
	echo 'Temporary directory variable $TEMP not set or pointing to a wrong directory' >&2
	echo >&2

	exit 2
fi


#
# Generate the sql script to import the output data from the terminals simulators into the database
#
SQL_SCRIPT_NAME="${TEMP}/${TEST_CASE_NAME}_missing_txn.sql"

cat > "$SQL_SCRIPT_NAME" <<END
USE experiment;

DROP TABLE IF EXISTS processed_txn_from_terminals;

CREATE TABLE processed_txn_from_terminals
(
	merchant_id varchar(15) not null,
	terminal_id varchar(8) not null,
	stan integer not null,
	card_scheme integer not null,
	function_code smallint not null, 
	amount decimal(19,2) not null,
	action_code smallint
);


LOCK TABLES processed_txn_from_terminals WRITE;
END


cat ${TEST_CASE_FULLPATH}/termsimul/Processed_*.txt | 
awk -F"," '{ print "('\''" $3 "'\'','\''" $4 "'\''," $5 "," $7 "," $8 "," $6 "/100," $9 ")" }' |
awk '{ if(NR==1||NR%1200==0) print ";INSERT INTO processed_txn_from_terminals VALUES " $1; else print "," $1 }'  >> "$SQL_SCRIPT_NAME"

echo ";" >> "$SQL_SCRIPT_NAME"

echo "UNLOCK TABLES;" >> "$SQL_SCRIPT_NAME"

cat "$SQL_SCRIPT_NAME" | mysql experiment

rm "$SQL_SCRIPT_NAME"

mysql experiment -e 'SET sql_mode=(SELECT CONCAT(@@sql_mode,",PIPES_AS_CONCAT")); SELECT merchant_id || "," || terminal_id || "," || stan || ","  || card_scheme || "," || function_code || "," || CONVERT(amount*100, CHAR) || "," || action_code AS CSV FROM processed_txn_from_terminals p WHERE NOT EXISTS ( SELECT 1 FROM transaction_log t where t.merchant_id = p.merchant_id AND t.terminal_id = p.terminal_id AND t.stan = p.stan );' |  awk '(NR>1)' > "${TEST_CASE_FULLPATH}/MissingTxnReport.txt"

mysql -v experiment -e "DROP TABLE processed_txn_from_terminals;" 

