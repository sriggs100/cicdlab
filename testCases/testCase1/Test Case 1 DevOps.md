# Test case 1 (DevOps): 

Modify column transaction_log.merchant_category_code from SMALLINT NOT NULL to VARCHAR(4) NOT NULL

## DevOps procedure:

1. Create a new table transaction_log1 with the new layout
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
8. Redeploy Acquirer's simulators (workers) with the db1_devops0 database layer which consists of using transaction_log as the primary table with fail over to transaction_log1 in case of updates (responses) error
9. Redeploy Acquirer's simulators (workers) with the db1_devops1 database layer which consists of using transaction_log1 as the primary table with fail over to transaction_log in case of error
10. Remove the foreign keys and triggers from the transaction_log table
11. Remove transaction_log (legacy) table
12. Rename transaction_log1 to transaction_log table
13. Create a view with the name transaction_log1 pointing to the transaction_log table to minimize latency
14. Redeploy Acquirer's simulators (workers) with the definitive db layer (new layout with transaction_log as table name)
15. Drop transaction_log1 view


