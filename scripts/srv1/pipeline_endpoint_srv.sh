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


# Script $HOME/bin/pipeline_endpoint_srv.sh

# Usually executed as: nohup ~/bin/pipeline_endpoint_srv.sh &

# This script creates a simple http server using netcat to receive information about new releases from the AWS pipeline
# Whenever a POST request comes from the pipeline its contents are appended to 

ENDPOINT_PORT=54167


SCRNAME=`basename $0`


echo "`date` $SCRNAME - STARTING"


# sudo ufw allow $ENDPOINT_PORT
while true
do 
	echo -e "HTTP/1.1 200 OK\n\n $(date)" | nc -l -N -p $ENDPOINT_PORT | tee --append /tmp/POST_FROM_PIPELINE
	
	COMMIT_TYPE=`grep -i commit /tmp/POST_FROM_PIPELINE | tail -1 | awk '{ print $6 }'`
	
	mv /tmp/POST_FROM_PIPELINE /tmp/POST_FROM_${COMMIT_TYPE}_PIPELINE
done
