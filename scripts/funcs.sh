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


create_output_dirs()
{
	PREFIX=$1
	
	[ ! -d $PREFIX/termsimul ] && mkdir -p $PREFIX/termsimul
	[ ! -d $PREFIX/cssimul ] && mkdir -p $PREFIX/cssimul
}


#
#	wait_for_simulators() 
#
#	Depends on the following environment variables: 
#		OUTPUT_LOG_FILE, CSSIMUL_INSTANCE1_PID, CSSIMUL_INSTANCE2_PID, TERMSIMUL_INSTANCE1_PID and TERMSIMUL_INSTANCE2_PID
#
#	Updates the following environment variables: 
#		ERROR_CONDITION, CSSIMUL_INSTANCE1_RETCODE, CSSIMUL_INSTANCE2_RETCODE, TERMSIMUL_INSTANCE1_RETCODE and TERMSIMUL_INSTANCE2_RETCODE
#
wait_for_simulators()
{
	ALL_PROCESSES_FINISHED=0
	IS_CSSIMUL_INSTANCE1_RUNNING=1
	CSSIMUL_INSTANCE1_RETCODE=999
	IS_CSSIMUL_INSTANCE2_RUNNING=1
	CSSIMUL_INSTANCE2_RETCODE=999
	IS_TERMSIMUL_INSTANCE1_RUNNING=1
	TERMSIMUL_INSTANCE1_RETCODE=999
	IS_TERMSIMUL_INSTANCE2_RUNNING=1
	TERMSIMUL_INSTANCE2_RETCODE=999
	ERROR_CONDITION=0
	SHUTDOWN_COMMAND_SENT=0

	while [ ${ALL_PROCESSES_FINISHED} -eq 0 ]
	do
		ALL_PROCESSES_FINISHED=1
		
		if [ ${IS_CSSIMUL_INSTANCE1_RUNNING} -eq 1 ]
		then
			if kill -0 $CSSIMUL_INSTANCE1_PID 2>/dev/null
			then
				# The process is still running
				ALL_PROCESSES_FINISHED=0
			else
				IS_CSSIMUL_INSTANCE1_RUNNING=0
				wait $CSSIMUL_INSTANCE1_PID
				CSSIMUL_INSTANCE1_RETCODE=$?
				
				echo -e "\nCard Scheme simulator with PID=${CSSIMUL_INSTANCE1_PID} returned with exit code ${CSSIMUL_INSTANCE1_RETCODE} on `date`\n" >> ${OUTPUT_LOG_FILE}
			fi
		fi
		
		if [ ${IS_CSSIMUL_INSTANCE2_RUNNING} -eq 1 ]
		then
			if kill -0 $CSSIMUL_INSTANCE2_PID 2>/dev/null
			then
				# The process is still running
				ALL_PROCESSES_FINISHED=0
			else
				IS_CSSIMUL_INSTANCE2_RUNNING=0
				wait $CSSIMUL_INSTANCE2_PID
				CSSIMUL_INSTANCE2_RETCODE=$?
				
				echo -e "\nCard Scheme simulator with PID=${CSSIMUL_INSTANCE2_PID} returned with exit code ${CSSIMUL_INSTANCE2_RETCODE} on `date`\n" >> ${OUTPUT_LOG_FILE}
			fi
		fi

		
		if [ ${IS_TERMSIMUL_INSTANCE1_RUNNING} -eq 1 ]
		then
			if kill -0 $TERMSIMUL_INSTANCE1_PID 2>/dev/null
			then
				# The process is still running
				ALL_PROCESSES_FINISHED=0
			else
				IS_TERMSIMUL_INSTANCE1_RUNNING=0
				wait $TERMSIMUL_INSTANCE1_PID
				TERMSIMUL_INSTANCE1_RETCODE=$?
				
				echo -e "\nTerminal simulator with PID=${TERMSIMUL_INSTANCE1_PID} returned with exit code ${TERMSIMUL_INSTANCE1_RETCODE} on `date`\n" >> ${OUTPUT_LOG_FILE}
			fi
		fi
		
		if [ ${IS_TERMSIMUL_INSTANCE2_RUNNING} -eq 1 ]
		then
			if kill -0 $TERMSIMUL_INSTANCE2_PID 2>/dev/null
			then
				# The process is still running
				ALL_PROCESSES_FINISHED=0
			else
				IS_TERMSIMUL_INSTANCE2_RUNNING=0
				wait $TERMSIMUL_INSTANCE2_PID
				TERMSIMUL_INSTANCE2_RETCODE=$?
				
				echo -e "\nTerminal simulator with PID=${TERMSIMUL_INSTANCE2_PID} returned with exit code ${TERMSIMUL_INSTANCE2_RETCODE} on `date`\n" >> ${OUTPUT_LOG_FILE}
			fi
		fi
		
		
		if [ $ERROR_CONDITION -eq 0 -a $SHUTDOWN_COMMAND_SENT -eq 0 ]
		then
			if [ ${IS_TERMSIMUL_INSTANCE1_RUNNING} -eq 0 -a ${IS_TERMSIMUL_INSTANCE2_RUNNING} -eq 0 ]
			then
				# Both terminal simulator instances are finished. The processing is finished. We need to shutdown the Card Scheme Simulators
				
				echo -e "\nTerminal simulators are finished. About to shutdown the CS simulators on `date`\n" >> ${OUTPUT_LOG_FILE}
				
				kill -USR1 $CSSIMUL_INSTANCE1_PID $CSSIMUL_INSTANCE2_PID
				
				SHUTDOWN_COMMAND_SENT=1
				
				# Wait for a few seconds
				
				sleep 5

			else
			
				if [ ${IS_CSSIMUL_INSTANCE1_RUNNING} -eq 0 -o ${IS_CSSIMUL_INSTANCE2_RUNNING} -eq 0 ]
				then
					
					echo -e "\nERROR - Card Scheme simulators finished before Terminal simulators. This shouldn't happen. About to shutdown the terminals simulators on `date`\n" >> ${OUTPUT_LOG_FILE}
					
					kill $TERMSIMUL_INSTANCE1_PID $TERMSIMUL_INSTANCE2_PID
					
					ERROR_CONDITION=1;
				fi
			fi
		fi

		sleep 10
	done
}

are_terminals_simulators_running()
{
	SIMUL1=0
	SIMUL2=0
	
	if kill -0 $TERMSIMUL_INSTANCE1_PID 2>/dev/null
	then
		SIMUL1=1
	fi
	
	if kill -0 $TERMSIMUL_INSTANCE2_PID 2>/dev/null
	then
		SIMUL2=1
	fi
	
	if [ $SIMUL1 -ne 1 -o $SIMUL2 -ne 1 ]
	then
		# NO
		return 1	
	fi
	
	# YES
	return 0
}


clean_activemq_db()
{
	purge_activemq_queues
}


start_acqsimul()
{
	stop_acqsimul
	
	ssh -n -p 8246 activemq@acqsimul '/home/activemq/bin/start.sh' >> ${OUTPUT_LOG_FILE} 2>&1 
	
	sleep 2
	
	clean_activemq_db
	
	ssh -n -p 8246 cicdlab@acqsimul 'cd /home/cicdlab/cicdlab; /home/cicdlab/cicdlab/build/scripts/start_acqsimul.sh 2>&1 >/dev/null'
}

stop_acqsimul()
{
	ssh -n -p 8246 cicdlab@acqsimul 'cd /home/cicdlab/cicdlab; /home/cicdlab/cicdlab/build/scripts/stop_acqsimul.sh 2>&1 >/dev/null'
	
	ssh -n -p 8246 activemq@acqsimul '/home/activemq/bin/stop.sh' >> ${OUTPUT_LOG_FILE} 2>&1 
}

killall_simulators()
{
	PIDS="`ps waux -u cicdlab  |grep "java.*simul" | grep -v grep | awk '{ print $2 }'`"
	[ -n "$PIDS" ] && kill $PIDS
	
	stop_acqsimul
}


restart_acqsimul_workers()
{
	curl -X POST acqsimul:9090/actuator/shutdown >> ${OUTPUT_LOG_FILE} 2>&1  &
	PIDS=$!
	echo -e "\nAcqsimul worker 1 shutdown command sent on `date`" >> ${OUTPUT_LOG_FILE}

	sleep 60

	curl -X POST acqsimul:9091/actuator/shutdown >> ${OUTPUT_LOG_FILE} 2>&1 &
	PIDS="$PIDS $!"
	echo -e "\nAcqsimul worker 2 shutdown command sent on `date`" >> ${OUTPUT_LOG_FILE}

	sleep 60

	curl -X POST acqsimul:9092/actuator/shutdown >> ${OUTPUT_LOG_FILE} 2>&1 &
	PIDS="$PIDS $!"
	echo -e "\nAcqsimul worker 3 shutdown command sent on `date`" >> ${OUTPUT_LOG_FILE}

	sleep 60

	curl -X POST acqsimul:9093/actuator/shutdown >> ${OUTPUT_LOG_FILE} 2>&1 &
	PIDS="$PIDS $!"
	echo -e "\nAcqsimul worker 4 shutdown command sent on `date`" >> ${OUTPUT_LOG_FILE}
	
	wait $PIDS
}


restart_acqsimul_workers_all_at_once()
{
	curl -X POST acqsimul:9090/actuator/shutdown >> ${OUTPUT_LOG_FILE} 2>&1 &
	PIDS=$!
	echo -e "\nAcqsimul worker 1 shutdown command sent on `date`" >> ${OUTPUT_LOG_FILE}

	curl -X POST acqsimul:9091/actuator/shutdown >> ${OUTPUT_LOG_FILE} 2>&1 &
	PIDS="$PIDS $!"
	echo -e "\nAcqsimul worker 2 shutdown command sent on `date`" >> ${OUTPUT_LOG_FILE}

	curl -X POST acqsimul:9092/actuator/shutdown >> ${OUTPUT_LOG_FILE} 2>&1 &
	PIDS="$PIDS $!"
	echo -e "\nAcqsimul worker 3 shutdown command sent on `date`" >> ${OUTPUT_LOG_FILE}

	curl -X POST acqsimul:9093/actuator/shutdown >> ${OUTPUT_LOG_FILE} 2>&1 &
	PIDS="$PIDS $!"
	echo -e "\nAcqsimul worker 4 shutdown command sent on `date`" >> ${OUTPUT_LOG_FILE}
	
	wait $PIDS
}



reset_acqsimul_db_config()
{
	DBLAYER=$1
	ssh -n -p 8246 cicdlab@acqsimul "echo /home/cicdlab/cicdlab/build/$DBLAYER"' > /tmp/CURRENT_ACQSIMUL_OBJECT_NAME'
}


purge_activemq_queues()
{
	ssh -n -p 8246 activemq@acqsimul '/home/activemq/bin/purge.sh' >> ${OUTPUT_LOG_FILE} 2>&1 
}

collect_log_files()
{
	TESTDIR=/home/cicdlab/cicdlab/$1
	
	echo "About to collect log files" >> ${OUTPUT_LOG_FILE}
	
	cd /var/log
	
	tar -mpcf - term | gzip -9c > ${TESTDIR}/termsimul_logs.tar.gz 2>>${OUTPUT_LOG_FILE}
	rm -rf /var/log/term; mkdir /var/log/term
	
	tar -mpcf - cs | gzip -9c > ${TESTDIR}/cssimul_logs.tar.gz 2>>${OUTPUT_LOG_FILE}
	rm -rf /var/log/cs; mkdir /var/log/cs
	
	cat monitor/monitor_srv1.log | gzip -9c > ${TESTDIR}/monitor_srv1.log.gz 2>>${OUTPUT_LOG_FILE}
	rm -rf /var/log/monitor; mkdir /var/log/monitor
	
	cd -
	
	ssh -n -p 8246 cicdlab@acqsimul 'cd /var/log; tar -mpcf - acq |gzip -9c' >${TESTDIR}/acqsimul_logs.tar.gz 2>>${OUTPUT_LOG_FILE}
	ssh -n -p 8246 cicdlab@acqsimul 'rm -rf /var/log/acq; mkdir /var/log/acq' >> ${OUTPUT_LOG_FILE} 2>&1 
	
	ssh -n -p 8246 cicdlab@dbhost 'cd /var/log; tar -mpcf - mysql |gzip -9c' >${TESTDIR}/mysql_logs.tar.gz 2>>${OUTPUT_LOG_FILE}
	
	ssh -n -p 8246 cicdlab@acqsimul 'cd /var/log; tar -mpcf - tomcat |gzip -9c' >${TESTDIR}/tomcat_logs.tar.gz 2>>${OUTPUT_LOG_FILE}
	ssh -n -p 8246 cicdlab@acqsimul 'rm -rf /var/log/tomcat; mkdir /var/log/tomcat' >> ${OUTPUT_LOG_FILE} 2>&1 
	
	ssh -n -p 8246 cicdlab@acqsimul 'cat /var/log/monitor/monitor_srv3.log |gzip -9c' >${TESTDIR}/monitor_srv3.log.gz 2>>${OUTPUT_LOG_FILE}
	ssh -n -p 8246 cicdlab@acqsimul 'rm -rf /var/log/monitor; mkdir /var/log/monitor' >> ${OUTPUT_LOG_FILE} 2>&1 
	
	ssh -n -p 8246 cicdlab@dbhost 'cat /var/log/monitor/monitor_srv2.log |gzip -9c' >${TESTDIR}/monitor_srv2.log.gz 2>>${OUTPUT_LOG_FILE}
	ssh -n -p 8246 cicdlab@dbhost 'rm -rf /var/log/monitor; mkdir /var/log/monitor'>> ${OUTPUT_LOG_FILE} 2>&1 
}


start_monitoring()
{
	/home/cicdlab/cicdlab/build/scripts/start_local_monitoring.sh >> ${OUTPUT_LOG_FILE}
	
	ssh -n -p 8246 cicdlab@acqsimul '/home/cicdlab/cicdlab/build/scripts/start_local_monitoring.sh >/dev/null 2>&1' >> ${OUTPUT_LOG_FILE} 2>&1
	
	ssh -n -p 8246 cicdlab@dbhost '/home/cicdlab/cicdlab/build/scripts/start_local_monitoring.sh >/dev/null 2>&1' >> ${OUTPUT_LOG_FILE} 2>&1
}

stop_monitoring()
{
	rm /tmp/LAB_TEST_RUNNING
	
	ssh -n -p 8246 cicdlab@acqsimul 'rm /tmp/LAB_TEST_RUNNING' >> ${OUTPUT_LOG_FILE} 2>&1
	
	ssh -n -p 8246 cicdlab@dbhost 'rm /tmp/LAB_TEST_RUNNING' >> ${OUTPUT_LOG_FILE} 2>&1
	
	sleep 15
}
