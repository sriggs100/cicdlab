
Automation scripts to run on srv1 server.

These scripts are to be installed under $HOME/bin and executed under $HOME/cicdlab


This server is the master server which commands the laboratory experiment execution
It is responsible for:
	- receive notifications from the AWS pipeline about new releases
	- Download all the necessary artifacts from AWS S3 object storage and redistribute them to all the servers involved in the experiment
	- Start the experiment and monitor its execution 
	- Once the execution is finished, gather all the results and log files from all the servers and process them
	
	
The current environment is composed by 3 servers as follows: 

srv1 (this server):

	- Runs the automation scripts
	- Hosts the Terminals simulator (termsimul) and Card Schemes simulators (cssimul)
	
	
srv2 (database host):

	- Hosts the mysql database
	
	
srv3 (acqsimul):

	- Hosts the Acquirer simulator
