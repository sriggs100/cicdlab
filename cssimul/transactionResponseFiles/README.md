
# Transaction responses files

transactionResponses_file1.csv.gz, transactionResponses_file2.csv.gz, transactionResponses_file3.csv.gz and transactionResponses_file4.csv.gz are CSV files containing the responses to the transactions injected to the system by the terminals simulator. These files contain the information that uniquely identifies a transaction as well as its response time.




Contents from files:

```
# Total transaction count
CNT=`gunzip -c cssimul/transactionResponseFiles/transactionResponses_file*.csv.gz | wc -l`
echo "CNT: $CNT"


# Total delay sum (milliseconds)
SUM=`gunzip -c cssimul/transactionResponseFiles/transactionResponses_file*.csv.gz | cut -d, -f1 | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum;}'`
echo "SUM: $SUM"


# Average simulated transaction delay:
AVG_DELAY=`echo "scale=2; $SUM/$CNT;"| bc`
echo "AVG_DELAY: $AVG_DELAY"

```


Output from the script execution:
```
CNT: 4611474
SUM: 4472647962.00
AVG_DELAY: 969.89
```