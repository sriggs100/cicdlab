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


# Script $HOME/bin/new_release_detector.sh

# Usually executed as: nohup ~/bin/new_release_detector.sh &


RELEASES_ALREADY_PROCESSED=$HOME/RELEASES_DB


SCRNAME=`basename $0`


echo "`date` $SCRNAME - STARTING"


is_already_processed()
{
	grep ${1}-${2} $RELEASES_ALREADY_PROCESSED
	if [ $? -eq 0 ]
	then
		return 1
	fi
	
	return 0
}

mark_as_processed()
{
	echo ${1}-${2} >> $RELEASES_ALREADY_PROCESSED
}


check_for_new_release()
{
	LINE=`grep "Commit Id:" /tmp/POST_FROM_*_PIPELINE | head -1`

	if [ -n "$LINE" ]
	then

		RELEASE_TYPE=`echo $LINE | awk '{ print $6 }'`
		COMMIT=`echo $LINE | awk '{ print $3 }'`
		
		> /tmp/POST_FROM_${RELEASE_TYPE}_PIPELINE
		
		is_already_processed ${RELEASE_TYPE} ${COMMIT}
		if [ $? -eq 0 ]
		then
			echo ${RELEASE_TYPE}:${COMMIT} > /tmp/NEW_${RELEASE_TYPE}_RELEASE
			
			mark_as_processed ${RELEASE_TYPE} ${COMMIT}
			
			echo "`date` $SCRNAME - New release detected with commit ${COMMIT}" 
		else
			echo "`date` $SCRNAME - New release with commit ${COMMIT} was already processed" 
		fi
	fi 
}


while true
do
	check_for_new_release
	
	sleep 10
done
