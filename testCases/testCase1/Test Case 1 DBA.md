# Test case 1 (DBA): 

Modify column transaction_log.merchant_category_code from SMALLINT NOT NULL to VARCHAR(4) NOT NULL

## Traditional DBA procedure:

1. Create a new table transaction_log_new with the new layout
   1. Ideally the new table would be an in-memory table, however the current table is too big to fit in memory (57.6GB)
2. Create a stored procedure to copy the data to the new table
   1. The stored procedure should be implemented in a way that the record is only copied if it doesn't exist in the new table
   2. The stored procedure should inform how many records have been copied
3. Execute the stored procedure several times until it informs that no records have been copied
   3. At this point we are sure that the new table is up-to-date with the data, however the data since the copy process has started has not been synchronized.
4. Create the indexes and constraints on the new table
5. Execute the stored procedure to copy the new data that has been generated during the previous copy process
6. Create triggers on the transaction_log table to update the new table
   1. Triggers for insert, delete and update operations
7. Execute the stored procedure to copy the new data that has been generated since the last execution
8. Remove the foreign keys from the transaction_log table
10. Inform the development team that the new table layout is ready
    1. The new table layout is ready however all the systems that access the table are still accessing the table with the old layout
11. As soon as the application is ready for the new layout, rename the tables
12. Remove the old table

