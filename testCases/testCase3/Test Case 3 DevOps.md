# Test case 3 (DevOps):

The creation of a new database table column transaction_log.transaction_token with NOT NULL UNIQUE constraints.


## DevOps procedure:

1. Reset the database data to Databaseline 0
2. Start simulators: Card Scheme, Acquirer and Terminals simulators.
3. Create a new table transaction_log1 with the new layout (new column transaction_token) with NOT NULL constraint without secondary indexes.
4. Create a stored procedure to copy the data to the new table and generate the token for the new col-umn. 
   1. The stored procedure should inform how many records have been copied.
5. Execute the stored procedure. 
   1. At this point we are sure that the new table is up to date with the data.
6. Create the secondary indexes and foreign keys on the new table.
7. Execute the stored procedure again to copy the new data inserted into the legacy table since the last time it executed.
8. Create triggers AFTER INSERT and AFTER UPDATE on the legacy table to replicate the commands on the new table and so keep it up to date.
9. Execute the stored procedure again to copy the new data inserted into the legacy table since the last time it executed.
10. Redeploy Acquirer's simulators (workers) with the db3_devops0 database layer which consists of using transaction_log as the primary table with fail over to transaction_log1 in case of updates (re-sponses) error.
11. Redeploy Acquirer's simulators (workers) with the db3_devops1 database layer which consists of using transaction_log1 as the primary table with fail over to transaction_log in case of error.
12. Remove the foreign keys and triggers from the transaction_log table.
13. Remove transaction_log (legacy) table.
14. Rename transaction_log1 to transaction_log table.
15. Create a view with the name transaction_log1 pointing to the transaction_log table to minimize laten-cy.
16. Redeploy Acquirer's simulators (workers) with the definitive database layer (new layout with transac-tion_log as table name)
17. Drop transaction_log1 view.
18. Wait for the simulators to finish.
19. Get logs and backup the resulting database.

