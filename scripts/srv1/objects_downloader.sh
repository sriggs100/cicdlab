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


# Script $HOME/bin/objects_downloader.sh

# Usually executed as: nohup ~/bin/objects_downloader.sh &


ENVIRONMENT_LOCK_FILE=/tmp/ENV_LOCKED

PROD_TMP_FILE=/tmp/NEW_MASTER_RELEASE
DEVELOP_TMP_FILE=/tmp/NEW_DEVELOP_RELEASE

PROD_S3_FILE="s3://cicdlab-bucket/CICDLabProd.zip"
DEVELOP_S3_FILE="s3://cicdlab-bucket/CICDLabTest.zip"

PROD_S3_COMMIT_FILE="s3://cicdlab-bucket/MASTER_Commit.id"
DEVELOP_S3_COMMIT_FILE="s3://cicdlab-bucket/DEVELOP_Commit.id"


SCRNAME=`basename $0`


echo "`date` $SCRNAME - STARTING"


wait_for_artifacts_file()
{
	ARTIFACTS_FILE=$PROD_S3_FILE
	COMMIT_FILE=$PROD_S3_COMMIT_FILE
	
	if [ "$1" = "DEVELOP" ]
	then
		ARTIFACTS_FILE=$DEVELOP_S3_FILE
		COMMIT_FILE=$DEVELOP_S3_COMMIT_FILE
	fi
	
	while true
	do
	
		COMMIT_FILE_TMESTAMP=`aws s3 ls $COMMIT_FILE | awk '{ print $1$2 }' | sed 's/[-:]//g'`
		ARTIFACTS_FILE_TMESTAMP=`aws s3 ls $ARTIFACTS_FILE | awk '{ print $1$2 }' | sed 's/[-:]//g'`
		
		if [ $ARTIFACTS_FILE_TMESTAMP -gt $COMMIT_FILE_TMESTAMP ]
		then
			break
		fi
		
		sleep 10
	done
}


download_artifacts_file()
{
	if [ "$1" = "DEVELOP" ]
	then
		aws s3 cp s3://cicdlab-bucket/CICDLabTest.zip ~/cicdlab
	else
		aws s3 cp s3://cicdlab-bucket/CICDLabProd.zip ~/cicdlab
	fi
}



download_artifacts()
{
	echo "`date` $SCRNAME - Waiting for the file to be ready for download"
	
	wait_for_artifacts_file $1 $2
	
	download_artifacts_file $1 $2
}



while true
do
	if [ ! -f $ENVIRONMENT_LOCK_FILE ]
	then
	
		if [ -f $DEVELOP_TMP_FILE ] 
		then
			touch $ENVIRONMENT_LOCK_FILE
			
			# Wait until the file is copied to S3
			sleep 15
			
			download_artifacts `awk -F: '{ print $1,$2 }' $DEVELOP_TMP_FILE` || { echo "`date` $SCRNAME - ERROR: CANNOT DOWNLOAD FILE FROM S3" && continue; }
			
			mv $DEVELOP_TMP_FILE /tmp/READY_DEVELOP_RELEASE
			
			echo "`date` $SCRNAME - Artifacts file downloaded - DEVELOP READY"
			
		elif [ -f $PROD_TMP_FILE ] 
		then
			touch $ENVIRONMENT_LOCK_FILE
			
			# Wait until the file is copied to S3
			sleep 15
			
			download_artifacts `awk -F: '{ print $1,$2 }' $PROD_TMP_FILE` || { echo "`date` $SCRNAME - ERROR: CANNOT DOWNLOAD FILE FROM S3" && continue; }
			
			mv $PROD_TMP_FILE /tmp/READY_MASTER_RELEASE
			
			echo "`date` $SCRNAME - Artifacts file downloaded - PROD READY"
		fi
	fi
	
	sleep 10
done
