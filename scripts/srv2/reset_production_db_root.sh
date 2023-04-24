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


# This script must run as root as follows:

# nohup ~cicdlab/bin/reset_production_db_root.sh &

DB_FILE_MIDSIZE=/home/cicdlab/cicdlab/db/production_env/mysql_dir_databaseline0_midsize.tar.gz
DB_FILE_PROD=/home/cicdlab/cicdlab/db/production_env/mysql_dir_databaseline0.tar.gz

#MYSQL_DATADIR=/var/lib/mysql

# DigitalOcean server:
MYSQL_DATADIR=/mnt/volume_lon1_01/cicdlab/db/mysql


while true
do
 if [ -f /tmp/RESET_MYSQL ]
 then

	RESET_TYPE=`cat /tmp/RESET_MYSQL`
	
	if [ "$RESET_TYPE" = "PROD" ]
	then
		DB_FILE=$DB_FILE_PROD
	else
		DB_FILE=$DB_FILE_MIDSIZE
	fi
	
	rm /tmp/RESET_MYSQL
	
	service mysql stop
	
	rm -rf $MYSQL_DATADIR
	
	cd `dirname ${MYSQL_DATADIR}`
	
	gunzip -c $DB_FILE | tar -xf -
	
	service mysql start
	
	touch /tmp/RESET_MYSQL_DONE ; chown cicdlab:cicdlab /tmp/RESET_MYSQL_DONE
 fi

 sleep 10
done
