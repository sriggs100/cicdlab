#!/usr/bin/bash

cd /opt/apache-activemq-5.17.2/bin
/opt/apache-activemq-5.17.2/bin/activemq stop

# Clean the database
rm -rf /opt/apache-activemq-5.17.2/data/kahadb
