
Automation scripts to run on srv2 server.

These scripts are to be installed under $HOME/bin and executed under $HOME/cicdlab


This server is the database server.

These scripts are responsible for resetting the Mysql database to databaseline0 before each test execution. They are 
necessary to save +9hs of processing time which would be necessary to reset the database by applying a restore 
operation. Instead, these scripts are meant to delete and recreate the /var/lib/mysql directory.

