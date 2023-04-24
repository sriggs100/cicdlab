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


# Script $HOME/bin/start_all.sh

SCRNAME=`basename $0`


echo "`date` $SCRNAME - STARTING"


is_already_running()
{
	PROCS=`ps waux |grep cicdlab | grep -E "pipeline_endpoint_srv|new_release_detector|objects_downloader|laboratory_tests_executor" | grep -v grep  | wc -l`
	
	if [ $PROCS -ne 0 ]
	then
		return 0
	fi	
	
	return 1
}


if is_already_running
then
	echo "`date` $SCRNAME - ERROR!! Some of the tasks are already running"
	
	exit 1
fi

cd ~/cicdlab

nohup ~/bin/pipeline_endpoint_srv.sh &
nohup ~/bin/new_release_detector.sh &
nohup ~/bin/objects_downloader.sh &
nohup ~/bin/laboratory_tests_executor.sh &

