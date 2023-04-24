# Test case 3: 

The creation of a new database table column transaction_log.transaction_token with NOT NULL UNIQUE constraints.


## Traditional DBA procedure:

1. Reset the database data to Databaseline 0
2. Start simulators: Card Scheme, Acquirer and Terminals simulators.
3. Create a new table transaction_log_new with the new layout (new column transaction_token) with NOT NULL constraint without secondary indexes.
4. Create a stored procedure to copy the data to the new table and generate the token for the new column.
   1. The stored procedure should inform how many records have been copied.
5. Execute the stored procedure.
   1. At this point we are sure that the new table is up to date with the data.
6. Create the secondary indexes and foreign keys on the new table.
7. Create triggers AFTER INSERT and AFTER UPDATE on the legacy table to replicate the commands on the new table and so keep it up to date.
8. Execute the stored procedure again to copy the new data inserted into the legacy table since the last time it executed.
9. Inform the development team that the new table layout is ready.
10. The new table layout is ready however all the systems that access the table are still accessing the table with the old layout.
11. As soon as the application is ready for the new layout, drop the triggers and the legacy table.
12. Wait for the simulators to finish.
13. Get logs and backup the resulting database.
