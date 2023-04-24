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

if [ $# -ne 2 -o -z "$RESULTS_XLSX_TEMPLATE" ]
then
	echo >&2
	echo "usage: process_results.sh <result's directory> <output directory>" >&2
	echo >&2
	echo "RESULTS_XLSX_TEMPLATE environment variable must point to the full path of the template spreadsheet" >&2

	exit 1
fi

RESULTS_DIR_FULLPATH=`realpath "$1"`
OUTPUT_DIR_FULLPATH=`realpath "$2"`
RESULTS_XLSX_TEMPLATE_FULLPATH=`realpath "$RESULTS_XLSX_TEMPLATE"`

REPORT_FILE_NAME=ValidateDbContent_AFTER_RUN.out

INITIAL_PWD=`pwd`
TEMP=/tmp

parse_test_case()
{
	CASE_FULLPATH=$1
	CASE_NAME=`basename $CASE_FULLPATH`

	cd "${CASE_FULLPATH}"
	
	INJECTED_APPROVED_CREDIT_VISA_TXN_QTY=`grep -A 2 INJECTED_APPROVED_CREDIT_VISA_TXN_QTY $REPORT_FILE_NAME | tail -1 | awk '{ print $6 }'`
	INJECTED_SUM_APPROVED_CREDIT_VISA_TXN_VALUE=`grep -A 2 INJECTED_SUM_APPROVED_CREDIT_VISA_TXN_VALUE $REPORT_FILE_NAME | tail -1 | awk '{ print $4 }'`
	APPROVED_CREDIT_VISA_TXN_QTY=`grep -v INJECTED $REPORT_FILE_NAME | grep -A 2 APPROVED_CREDIT_VISA_TXN_QTY  | tail -1 | awk '{ print $6 }'`
	SUM_APPROVED_CREDIT_VISA_TXN_VALUE=`grep -v INJECTED $REPORT_FILE_NAME | grep -A 2 SUM_APPROVED_CREDIT_VISA_TXN_VALUE | tail -1 | awk '{ print $4 }'`
	INJECTED_APPROVED_DEBIT_VISA_TXN_QTY=`grep -A 2 INJECTED_APPROVED_DEBIT_VISA_TXN_QTY $REPORT_FILE_NAME | tail -1 | awk '{ print $6 }'`
	INJECTED_SUM_APPROVED_DEBIT_VISA_TXN_VALUE=`grep -A 2 INJECTED_SUM_APPROVED_DEBIT_VISA_TXN_VALUE $REPORT_FILE_NAME | tail -1 | awk '{ print $4 }'`
	APPROVED_DEBIT_VISA_TXN_QTY=`grep -v INJECTED $REPORT_FILE_NAME | grep -A 2 APPROVED_DEBIT_VISA_TXN_QTY  | tail -1 | awk '{ print $6 }'`	
	SUM_APPROVED_DEBIT_VISA_TXN_VALUE=`grep -v INJECTED $REPORT_FILE_NAME | grep -A 2 SUM_APPROVED_DEBIT_VISA_TXN_VALUE | tail -1 | awk '{ print $4 }'`
	INJECTED_APPROVED_CREDIT_MC_TXN_QTY=`grep -A 2 INJECTED_APPROVED_CREDIT_MC_TXN_QTY $REPORT_FILE_NAME | tail -1 | awk '{ print $6 }'`
	INJECTED_SUM_APPROVED_CREDIT_MC_TXN_VALUE=`grep -A 2 INJECTED_SUM_APPROVED_CREDIT_MC_TXN_VALUE $REPORT_FILE_NAME | tail -1 | awk '{ print $4 }'`
	APPROVED_CREDIT_MC_TXN_QTY=`grep -v INJECTED $REPORT_FILE_NAME | grep -A 2 APPROVED_CREDIT_MC_TXN_QTY | tail -1 | awk '{ print $6 }'`
	SUM_APPROVED_CREDIT_MC_TXN_VALUE=`grep -v INJECTED $REPORT_FILE_NAME | grep -A 2 SUM_APPROVED_CREDIT_MC_TXN_VALUE | tail -1 | awk '{ print $4 }'`
	INJECTED_APPROVED_DEBIT_MC_TXN_QTY=`grep -A 2 INJECTED_APPROVED_DEBIT_MC_TXN_QTY $REPORT_FILE_NAME | tail -1 | awk '{ print $6 }'`
	INJECTED_SUM_APPROVED_DEBIT_MC_TXN_VALUE=`grep -A 2 INJECTED_SUM_APPROVED_DEBIT_MC_TXN_VALUE $REPORT_FILE_NAME | tail -1 | awk '{ print $4 }'`
	APPROVED_DEBIT_MC_TXN_QTY=`grep -v INJECTED $REPORT_FILE_NAME | grep -A 2 APPROVED_DEBIT_MC_TXN_QTY | tail -1 | awk '{ print $6 }'`
	SUM_APPROVED_DEBIT_MC_TXN_VALUE=`grep -v INJECTED $REPORT_FILE_NAME | grep -A 2 SUM_APPROVED_DEBIT_MC_TXN_VALUE | tail -1 | awk '{ print $4 }'`
	
	TERM_PROC_VISA_CREDIT=`cat termsimul/Processed_* 2>/dev/null | cut -d, -f6-9 | grep 0,100,000 | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum/100;}'`
	TERM_FAILED_VISA_CREDIT=`cat termsimul/Failed_* 2>/dev/null | cut -d, -f6-8 | grep ",0,100$" | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum/100;}'`
	TERM_NREPLIED_VISA_CREDIT=`cat termsimul/NotReplied_* 2>/dev/null | cut -d, -f6-8 | grep ",0,100$" | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum/100;}'`
	TERM_LR_VISA_CREDIT=`cat termsimul/LateResponse_* 2>/dev/null | cut -d, -f7-10 | grep ",0,100,000$" | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum/100;}'`
	TERM_PROC_VISA_DEBIT=`cat termsimul/Processed_* 2>/dev/null | cut -d, -f6-9 | grep 0,200,000 | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum/100;}'`
	TERM_FAILED_VISA_DEBIT=`cat termsimul/Failed_* 2>/dev/null | cut -d, -f6-8 | grep ",0,200$" | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum/100;}'`
	TERM_NREPLIED_VISA_DEBIT=`cat termsimul/NotReplied_* 2>/dev/null | cut -d, -f6-8 | grep ",0,200$" | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum/100;}'`
	TERM_LR_VISA_DEBIT=`cat termsimul/LateResponse_* 2>/dev/null | cut -d, -f7-10 | grep ",0,200,000$" | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum/100;}'`
	TERM_PROC_MC_CREDIT=`cat termsimul/Processed_* 2>/dev/null | cut -d, -f6-9 | grep 1,100,000 | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum/100;}'`
	TERM_FAILED_MC_CREDIT=`cat termsimul/Failed_* 2>/dev/null | cut -d, -f6-8 | grep ",1,100$" | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum/100;}'`
	TERM_NREPLIED_MC_CREDIT=`cat termsimul/NotReplied_* 2>/dev/null | cut -d, -f6-8 | grep ",1,100$" | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum/100;}'`
	TERM_LR_MC_CREDIT=`cat termsimul/LateResponse_* 2>/dev/null | cut -d, -f7-10 | grep ",1,100,000$" | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum/100;}'`
	TERM_PROC_MC_DEBIT=`cat termsimul/Processed_* 2>/dev/null | cut -d, -f6-9 | grep 1,200,000 | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum/100;}'`
	TERM_FAILED_MC_DEBIT=`cat termsimul/Failed_* 2>/dev/null | cut -d, -f6-8 | grep ",1,200$" | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum/100;}'`
	TERM_NREPLIED_MC_DEBIT=`cat termsimul/NotReplied_* 2>/dev/null | cut -d, -f6-8 | grep ",1,200$" | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum/100;}'`
	TERM_LR_MC_DEBIT=`cat termsimul/LateResponse_* 2>/dev/null | cut -d, -f7-10 | grep ",1,200,000$" | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum/100;}'`
	
	MISSING_PROC_VISA_CREDIT=`cat MissingTxnReport.txt 2>/dev/null | awk -F, '{ print $6 "," $4 "," $5 "," $7 }' | grep 0,100,0 | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum/100;}'`
	MISSING_PROC_VISA_DEBIT=`cat MissingTxnReport.txt 2>/dev/null | awk -F, '{ print $6 "," $4 "," $5 "," $7 }' | grep 0,200,0 | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum/100;}'`
	MISSING_PROC_MC_CREDIT=`cat MissingTxnReport.txt 2>/dev/null | awk -F, '{ print $6 "," $4 "," $5 "," $7 }' | grep 1,100,0 | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum/100;}'`
	MISSING_PROC_MC_DEBIT=`cat MissingTxnReport.txt 2>/dev/null | awk -F, '{ print $6 "," $4 "," $5 "," $7 }' | grep 1,200,0 | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum/100;}'`
	
	AVERAGE_RESPONSE_TIME_MILLIS=`cat termsimul/Statistics_* | cut -d "=" -f 3,5 --output-delimiter="," | cut -d "," -f 1,3 | awk -F',' '{sum1+=$1; sum2+=$2;} END{print sum1/sum2}'`

	STARTING_DATE=$(date -d "`grep "Starting case [0-3].* on " *.log | awk -F " on " '{ print $2 }'`" +%m-%d)
	
	cd -
}

generate_spreadsheet()
{
	TEST_CASE_NAME=$1
	
	CWD=$PWD
	
	cd $TEMP
	mkdir $TEST_CASE_NAME
	cd $TEST_CASE_NAME
	
	unzip -x "$RESULTS_XLSX_TEMPLATE_FULLPATH"
	
		
	# Eliminate calculated values
	cp -p xl/worksheets/sheet1.xml ${TEMP}
	cat ${TEMP}/sheet1.xml | awk '{ gsub(/<\/row>/, "</row>\n"); print }' | sed 's/<\/f><v>[0-9E\.\-]*<\/v>/<\/f>/g' | sed 's/\"\/><v>[0-9E\.\-]*<\/v>/\"\/>/g' > xl/worksheets/sheet1.xml


	sed -i "s/CASE_NAME/$CASE_NAME/" xl/sharedStrings.xml
	
	sed -i "s/11124000/$INJECTED_APPROVED_CREDIT_VISA_TXN_QTY/" xl/worksheets/sheet1.xml
	sed -i "s/11134000/$INJECTED_SUM_APPROVED_CREDIT_VISA_TXN_VALUE/" xl/worksheets/sheet1.xml
	sed -i "s/11154000/$APPROVED_CREDIT_VISA_TXN_QTY/" xl/worksheets/sheet1.xml
	sed -i "s/11164000/$SUM_APPROVED_CREDIT_VISA_TXN_VALUE/" xl/worksheets/sheet1.xml
	
	sed -i "s/11125000/$INJECTED_APPROVED_DEBIT_VISA_TXN_QTY/" xl/worksheets/sheet1.xml
	sed -i "s/11135000/$INJECTED_SUM_APPROVED_DEBIT_VISA_TXN_VALUE/" xl/worksheets/sheet1.xml
	sed -i "s/11155000/$APPROVED_DEBIT_VISA_TXN_QTY/" xl/worksheets/sheet1.xml
	sed -i "s/11165000/$SUM_APPROVED_DEBIT_VISA_TXN_VALUE/" xl/worksheets/sheet1.xml
	
	sed -i "s/11126000/$INJECTED_APPROVED_CREDIT_MC_TXN_QTY/" xl/worksheets/sheet1.xml
	sed -i "s/11136000/$INJECTED_SUM_APPROVED_CREDIT_MC_TXN_VALUE/" xl/worksheets/sheet1.xml
	sed -i "s/11156000/$APPROVED_CREDIT_MC_TXN_QTY/" xl/worksheets/sheet1.xml
	sed -i "s/11166000/$SUM_APPROVED_CREDIT_MC_TXN_VALUE/" xl/worksheets/sheet1.xml
	
	sed -i "s/11127000/$INJECTED_APPROVED_DEBIT_MC_TXN_QTY/" xl/worksheets/sheet1.xml
	sed -i "s/11137000/$INJECTED_SUM_APPROVED_DEBIT_MC_TXN_VALUE/" xl/worksheets/sheet1.xml
	sed -i "s/11157000/$APPROVED_DEBIT_MC_TXN_QTY/" xl/worksheets/sheet1.xml
	sed -i "s/11167000/$SUM_APPROVED_DEBIT_MC_TXN_VALUE/" xl/worksheets/sheet1.xml
	
	
	sed -i "s/11129000/$AVERAGE_RESPONSE_TIME_MILLIS/" xl/worksheets/sheet1.xml
	
	
	sed -i "s/111213000/$TERM_PROC_VISA_CREDIT/" xl/worksheets/sheet1.xml
	sed -i "s/111313000/$TERM_FAILED_VISA_CREDIT/" xl/worksheets/sheet1.xml
	sed -i "s/111413000/$TERM_NREPLIED_VISA_CREDIT/" xl/worksheets/sheet1.xml
	sed -i "s/111513000/$TERM_LR_VISA_CREDIT/" xl/worksheets/sheet1.xml
	
	sed -i "s/111214000/$TERM_PROC_VISA_DEBIT/" xl/worksheets/sheet1.xml
	sed -i "s/111314000/$TERM_FAILED_VISA_DEBIT/" xl/worksheets/sheet1.xml
	sed -i "s/111414000/$TERM_NREPLIED_VISA_DEBIT/" xl/worksheets/sheet1.xml
	sed -i "s/111514000/$TERM_LR_VISA_DEBIT/" xl/worksheets/sheet1.xml
	
	sed -i "s/111215000/$TERM_PROC_MC_CREDIT/" xl/worksheets/sheet1.xml
	sed -i "s/111315000/$TERM_FAILED_MC_CREDIT/" xl/worksheets/sheet1.xml
	sed -i "s/111415000/$TERM_NREPLIED_MC_CREDIT/" xl/worksheets/sheet1.xml
	sed -i "s/111515000/$TERM_LR_MC_CREDIT/" xl/worksheets/sheet1.xml
	
	sed -i "s/111216000/$TERM_PROC_MC_DEBIT/" xl/worksheets/sheet1.xml
	sed -i "s/111316000/$TERM_FAILED_MC_DEBIT/" xl/worksheets/sheet1.xml
	sed -i "s/111416000/$TERM_NREPLIED_MC_DEBIT/" xl/worksheets/sheet1.xml
	sed -i "s/111516000/$TERM_LR_MC_DEBIT/" xl/worksheets/sheet1.xml
	
	sed -i "s/333225333/$MISSING_PROC_VISA_CREDIT/" xl/worksheets/sheet1.xml
	sed -i "s/333226333/$MISSING_PROC_VISA_DEBIT/" xl/worksheets/sheet1.xml
	sed -i "s/333227333/$MISSING_PROC_MC_CREDIT/" xl/worksheets/sheet1.xml
	sed -i "s/333228333/$MISSING_PROC_MC_DEBIT/" xl/worksheets/sheet1.xml
	
	zip -r ${OUTPUT_DIR_FULLPATH}/${TEST_CASE_NAME}/${TEST_CASE_NAME}_${STARTING_DATE}.xlsx *
	
	cd ..
	rm -rf $TEST_CASE_NAME
	
	cd $CWD
}

AVAILABLE_TEST_RESULTS=`ls -1d ${RESULTS_DIR_FULLPATH}/test* | grep -v .xlsx`
#AVAILABLE_TEST_RESULTS=`ls -1d ${RESULTS_DIR_FULLPATH}/test1_devops`

for TEST_FULLPATH in $AVAILABLE_TEST_RESULTS
do
	TEST_CASE_NAME=`basename $TEST_FULLPATH`
	echo "Processing test case: $TEST_CASE_NAME"
	
	parse_test_case $TEST_FULLPATH

	generate_spreadsheet $TEST_CASE_NAME
done


