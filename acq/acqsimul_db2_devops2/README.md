

# Acquirer Simulator database layer 1 / DevOps 1

Contains the source code of the database layer 1, which is the database model with the following change to the entities:


```
public class TransactionLog {
...
//    @Column(nullable = false)
//    private Short merchantCategoryCode;
    @Column(nullable = false, length = 4)
    private String merchantCategoryCode;
    
public class TransactionLog1 {
...
//    @Column(nullable = false)
//    private Short merchantCategoryCode;
    @Column(nullable = false, length = 4)
    private String merchantCategoryCode;
    
```

which translates to the following change on database tables:

```
create table transaction_log (
...
    -- merchant_category_code smallint not null,
    merchant_category_code varchar(4) not null
    
create table transaction_log1 (
...
    -- merchant_category_code smallint not null,
    merchant_category_code varchar(4) not null
    
```


Used in DevOps Test Case 1 to allow a failover to transaction_log table whenever there's an error accessing transaction_log1 table   
