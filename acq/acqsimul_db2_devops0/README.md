

# Acquirer Simulator database layer 2 DevOps 0

Contains the source code of the database layer 2 for DevOps strategy, which is the database model with the following change to the entities:


```
public class TransactionLog {
...
    @Column(nullable = true, length = 4)
    private String applicationTransactionCounter;
...
}

public class TransactionEmvData {
...
    @Column(nullable = true, length = 4)
    private String applicationTransactionCounter;
...
}
    
```

which translates to the following change on database tables:

```
create table transaction_log (
...
    application_transaction_counter varchar(4),
...
);
    
create table transaction_emv_data (
...
    application_expiration_date varchar(4),
...
);
    
```


Used in Test Case 2 with DevOps strategy
