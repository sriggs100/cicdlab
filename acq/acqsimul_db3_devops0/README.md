

# Acquirer Simulator database layer 1 / DevOps 0

Contains the source code of the database layer 1, which is the database model with the following change to the entities:


```
public class TransactionLog {
...
    @Transient
    //@Column(nullable = false, length = 36, unique = false)
    private String transactionToken;

...

public class TransactionLog1 {
...
    @Column(nullable = false, length = 36, unique = false)
    private String transactionToken;
...
}
```

which translates to the following change on database tables:

```
CREATE TABLE transaction_log1 (
...
    transaction_token VARCHAR(36) NOT NULL,
...
);
```


Used in DevOps Test Case 1 to use transaction_log table as a primary table for insertion and update, whilst allowing to fallback to transaction_log1 whenever there's an error updating transaction_log table   
