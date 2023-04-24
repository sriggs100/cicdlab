

# Acquirer Simulator database layer 3

Contains the source code of the database layer 3, which is the database model with the following change to the entities:


```
@Table(indexes = {
...
        uniqueConstraints = {
        ...
        @UniqueConstraint(name = "UniqueTransactionToken", columnNames = { "transactionToken" }),
        })
public class TransactionLog {
...
    @Column(nullable = false, length = 36, unique = true)
    private String transactionToken;
...
}
```

which translates to the following change on database tables:

```
CREATE TABLE transaction_log (
...
    transaction_token VARCHAR(36) NOT NULL,
...
);
    
ALTER TABLE `experiment`.`transaction_log` 
    ADD UNIQUE INDEX `UniqueTransactionToken` (`stan` ASC) VISIBLE;
```


Used in Test Case 3
