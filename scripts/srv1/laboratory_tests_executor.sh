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


# Script $HOME/bin/laboratory_tests_executor.sh

# Usually executed as: nohup ~/bin/laboratory_tests_executor.sh &

#SINGLE_SERVER=1
SINGLE_SERVER=0

ENVIRONMENT_LOCK_FILE=/tmp/ENV_LOCKED

PROD_TMP_FILE=/tmp/READY_MASTER_RELEASE
DEVELOP_TMP_FILE=/tmp/READY_DEVELOP_RELEASE


SCRNAME=`basename $0`


echo "`date` $SCRNAME - STARTING"


rm $PROD_TMP_FILE $DEVELOP_TMP_FILE $ENVIRONMENT_LOCK_FILE


transfer_artifacts()
{
	scp -P 8246 $1 $2
}

prepare_develop_environment()
{
	unzip -o CICDLabTest.zip || { echo "`date` $SCRNAME - ERROR: CANNOT UNZIP DEVELOP FILE" && return 1; }
	
	if [ $SINGLE_SERVER -ne 1 ]
	then
		transfer_artifacts CICDLabTest.zip cicdlab@srv2:/home/cicdlab/cicdlab || { echo "`date` $SCRNAME - ERROR: CANNOT TRANSFER DEVELOP FILE (1)" && return 1; }
		
		ssh -p 8246 cicdlab@srv2 'cd /home/cicdlab/cicdlab && unzip -o CICDLabTest.zip' || { echo "`date` $SCRNAME - ERROR: CANNOT UNZIP DEVELOP FILE (1)" && return 1; }
		
		transfer_artifacts CICDLabTest.zip cicdlab@srv3:/home/cicdlab/cicdlab || { echo "`date` $SCRNAME - ERROR: CANNOT TRANSFER DEVELOP FILE (2)" && return 1; }
		
		ssh -p 8246 cicdlab@srv3 'cd /home/cicdlab/cicdlab && unzip -o CICDLabTest.zip' || { echo "`date` $SCRNAME - ERROR: CANNOT UNZIP DEVELOP FILE (2)" && return 1; }
	fi
	
	return 0
}

prepare_production_environment()
{
	unzip -o CICDLabProd.zip || { echo "`date` $SCRNAME - ERROR: CANNOT UNZIP PRODUCTION FILE" && return 1; }

	if [ $SINGLE_SERVER -ne 1 ]
	then
		transfer_artifacts CICDLabProd.zip cicdlab@srv2:/home/cicdlab/cicdlab || { echo "`date` $SCRNAME - ERROR: CANNOT TRANSFER PRODUCTION FILE (1)" && return 1; }
		
		ssh -p 8246 cicdlab@srv2 'cd /home/cicdlab/cicdlab && unzip -o CICDLabProd.zip' || { echo "`date` $SCRNAME - ERROR: CANNOT UNZIP PRODUCTION FILE (1)" && return 1; }
		
		transfer_artifacts CICDLabProd.zip cicdlab@srv3:/home/cicdlab/cicdlab || { echo "`date` $SCRNAME - ERROR: CANNOT TRANSFER PRODUCTION FILE (2)" && return 1; }
		
		ssh -p 8246 cicdlab@srv3 'cd /home/cicdlab/cicdlab && unzip -o CICDLabProd.zip' || { echo "`date` $SCRNAME - ERROR: CANNOT UNZIP PRODUCTION FILE (2)" && return 1; }
	fi
	
	return 0
}


while true
do
	sleep 10
	
	if [ -f $DEVELOP_TMP_FILE ] 
	then

		[ ! -f $ENVIRONMENT_LOCK_FILE ] && { echo "`date` $SCRNAME - Environment not locked.. Not processing" && continue; }

		echo "`date` $SCRNAME - About to process DEVELOP Tests"
		
		mv $DEVELOP_TMP_FILE /tmp/PROCESSING_DEVELOP_RELEASE

		prepare_develop_environment || break
		
		echo "`date` $SCRNAME - About to start DEVELOP Tests"
		
		~/cicdlab/build/scripts/run_test_cases.sh TEST || { echo "`date` $SCRNAME - ERROR: PROCESSING DEVELOP TESTS" && break; }
		
		mv /tmp/PROCESSING_DEVELOP_RELEASE /tmp/DONE_DEVELOP_RELEASE
		rm $ENVIRONMENT_LOCK_FILE
		
	elif [ -f $PROD_TMP_FILE ] 
	then
	
		[ ! -f $ENVIRONMENT_LOCK_FILE ] && { echo "`date` $SCRNAME - Environment not locked.. Not processing" && continue; }
	
		echo "`date` $SCRNAME - About to process PRODUCTION Tests"
		
		mv $PROD_TMP_FILE /tmp/PROCESSING_MASTER_RELEASE
	
		prepare_production_environment || break
	
		echo "`date` $SCRNAME - About to start PRODUCTION Tests"
	
		~/cicdlab/build/scripts/run_test_cases.sh PROD || { echo "`date` $SCRNAME - ERROR: PROCESSING PRODUCTION TESTS" && break; }
		
		mv /tmp/PROCESSING_MASTER_RELEASE /tmp/DONE_MASTER_RELEASE
		rm $ENVIRONMENT_LOCK_FILE
	fi	
done
