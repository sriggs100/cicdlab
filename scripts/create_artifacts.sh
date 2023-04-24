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
 
 
BUILD_DIR=build
SCRIPTS_DIR=${BUILD_DIR}/scripts
CONFIG_DIR=${BUILD_DIR}/config

[ ! -d $BUILD_DIR ] && mkdir $BUILD_DIR
[ ! -d $SCRIPTS_DIR ] && mkdir $SCRIPTS_DIR
[ ! -d $CONFIG_DIR ] && mkdir $CONFIG_DIR


set > ${BUILD_DIR}/env_vars.txt
cp -p termsimul/build/libs/termsimul-*-SNAPSHOT.jar $BUILD_DIR
cp -p termsimul/transactionFiles/transactions_file*.csv.gz $BUILD_DIR
cp -p cssimul/build/libs/cssimul-*-SNAPSHOT.jar $BUILD_DIR
cp -p cssimul/transactionResponseFiles/transactionResponses_file*.csv.gz $BUILD_DIR

chmod +x scripts/*.sh
cp -p scripts/*.sh $SCRIPTS_DIR
cp -p scripts/*.sql $SCRIPTS_DIR

# Get S3 bucket files for the environment
if [ "${BUILD_TYPE}" == "DEVELOP" ]
then
	S3_DIR=test_env
else
	S3_DIR=production_env
fi

aws s3 cp s3://${S3_BUCKET}/${S3_DIR} $CONFIG_DIR --recursive

cp -p config/Procfile .
