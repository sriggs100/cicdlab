

# Acquirer Simulator database layer 1 / DevOps 0

Contains the source code of the database layer 1, which is the database model with the following change to the entities:


```
    
public class TransactionLog1 {
...
//    @Column(nullable = false)
//    private Short merchantCategoryCode;
    @Column(nullable = false, length = 4)
    private String merchantCategoryCode;
    
```

which translates to the following change on database tables:

```
create table transaction_log1 (
...
    -- merchant_category_code smallint not null,
    merchant_category_code varchar(4) not null
    
```


Used in DevOps Test Case 1 to use transaction_log table as a primary table for insertion and update, whilst allowing to fallback to transaction_log1 whenever there's an error updating transaction_log table   
