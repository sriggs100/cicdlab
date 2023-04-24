# Test case 2 (DevOps): 

Migrate column transaction_log.application_transaction_counter varchar(4) to transaction_emv_data table using DevOps approach


## DevOps procedure:

1. Create a new table column transaction_emv_data.application_transaction_counter varchar(4)
2. Change the application's database layer to support the new layout (updating both, the legacy column as well as the new column) and deploy
3. Create a stored procedure to copy the data to the new table column
   1. The stored procedure should be implemented in a way that the field content is only updated if it doesn't exist in the new table
   2. The stored procedure should inform how many records have been updated
4. Execute the stored procedure several times until it informs that no updates have been performed
   1. At this point we are sure that the new table is up-to-date with the data
5. Change the application's database layer to support the new layout (updating only the new column) and deploy
6. Remove transaction_log.application_transaction_counter column

