# Test case 2 (DBA): 

Migrate column transaction_log.application_transaction_counter varchar(4) to transaction_emv_data table

## Traditional DBA procedure:

1. Create a new column transaction_emv_data.application_transaction_counter varchar(4)
2. Create triggers on the transaction_log table to update the new table column on transaction_emv_data
   1. Triggers for insert, delete and update operations
3. Create a stored procedure to copy the data to the new table column
   1. The stored procedure should be implemented in a way that the field content is only updated if it doesn't exist in the new table
   2. The stored procedure should inform how many records have been updated
4. Execute the stored procedure several times until it informs that no updates have been performed
   1. At this point we are sure that the new table is up-to-date with the data
5. Inform the development team that the new table layout is ready
   1. The new table layout is ready however all the systems that access the table are still accessing the table with the old layout
6. As soon as the application is ready for the new layout, drop the triggers and remove transaction_log.application_transaction_counter column
