

# Acquirer Simulator database layer 1 / DevOps 1

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

Used in DevOps Test Case 1 to allow a failover to transaction_log table whenever there's an error accessing transaction_log1 table   
