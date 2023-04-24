

transactions_file1.csv.gz, transactions_file2.csv.gz, transactions_file3.csv.gz and transactions_file4.csv.gz are CSV files containing the transactions to be injected to the system by the terminals simulator.



Contents from files: 

```
# Credit transactions:
CREDIT_CNT=`gunzip -c  termsimul/transactionFiles/transactions_file*.csv.gz | cut -d, -f9 | grep 100 | wc -l`
echo "CREDIT_CNT: $CREDIT_CNT"


# Debit transactions:
DEBIT_CNT=`gunzip -c  termsimul/transactionFiles/transactions_file*.csv.gz | cut -d, -f9 | grep 200 | wc -l`
echo "DEBIT_CNT: $DEBIT_CNT"


# Total transactions: 
LINES=`gunzip -c  termsimul/transactionFiles/transactions_file*.csv.gz | wc -l`
echo "LINES: $(($LINES-2))"	# remove header lines



# Visa transactions: 
VISA_CNT=`gunzip -c  termsimul/transactionFiles/transactions_file*.csv.gz | cut -d, -f7 | grep 0 | wc -l`
echo "VISA_CNT:$VISA_CNT"


# Visa Credit transactions: 
VISA_CREDIT_CNT=`gunzip -c  termsimul/transactionFiles/transactions_file*.csv.gz | cut -d, -f7,9 | grep "0,100" | wc -l`
echo "VISA_CREDIT_CNT: $VISA_CREDIT_CNT"


# Visa Debit transactions: 
VISA_DEBIT_CNT=`gunzip -c  termsimul/transactionFiles/transactions_file*.csv.gz | cut -d, -f7,9 | grep "0,200" | wc -l`
echo "VISA_DEBIT_CNT: $VISA_DEBIT_CNT"


# MasterCard transactions: 
MC_CNT=`gunzip -c  termsimul/transactionFiles/transactions_file*.csv.gz | cut -d, -f7 | grep 1 | wc -l`
echo "MC_CNT: $MC_CNT"


# Master Card Credit transactions: 
MC_CREDIT_CNT=`gunzip -c  termsimul/transactionFiles/transactions_file*.csv.gz | cut -d, -f7,9 | grep "1,100" | wc -l`
echo "MC_CREDIT_CNT: $MC_CREDIT_CNT"


# Master Card Debit transactions: 
MC_DEBIT_CNT=`gunzip -c  termsimul/transactionFiles/transactions_file*.csv.gz | cut -d, -f7,9 | grep "1,200" | wc -l`
echo "MC_DEBIT_CNT: $MC_DEBIT_CNT"


# Master Card percentual
MC_PERC=`echo "scale=2; $MC_CNT/($MC_CNT+$VISA_CNT)*100;"| bc`
echo "MC_PERC: $MC_PERC"


# Credit transactions percentual
CREDIT_PERC=`echo "scale=2; $CREDIT_CNT/($CREDIT_CNT+$DEBIT_CNT)*100;"| bc`
echo "CREDIT_PERC: $CREDIT_PERC"


# Total SUM Credit transactions:
CREDIT_SUM=`gunzip -c  termsimul/transactionFiles/transactions_file*.csv.gz | cut -d, -f3,9 | grep ,100$ | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum;}'`
echo "CREDIT_SUM: $CREDIT_SUM"


# Average Amount Credit transactions:
AVG_AMT_CREDIT=`echo "scale=2; $CREDIT_SUM/$CREDIT_CNT;"| bc`
echo "AVG_AMT_CREDIT: $AVG_AMT_CREDIT"


# Total SUM Debit transactions:
DEBIT_SUM=`gunzip -c  termsimul/transactionFiles/transactions_file*.csv.gz | cut -d, -f3,9 | grep ,200$ | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum;}'`
echo "DEBIT_SUM: $DEBIT_SUM"


# Average Amount Debit transactions:
AVG_AMT_DEBIT=`echo "scale=2; $DEBIT_SUM/$DEBIT_CNT;"| bc`
echo "AVG_AMT_DEBIT: $AVG_AMT_DEBIT"


# Visa Sum Credit transactions:
VISA_CREDIT_SUM=`gunzip -c  termsimul/transactionFiles/transactions_file*.csv.gz | cut -d, -f3,7,9 | grep 0,100$ | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum;}'`
echo "VISA_CREDIT_SUM: $VISA_CREDIT_SUM"


# Visa Sum Debit transactions:
VISA_DEBIT_SUM=`gunzip -c  termsimul/transactionFiles/transactions_file*.csv.gz | cut -d, -f3,7,9 | grep 0,200$ | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum;}'`
echo "VISA_DEBIT_SUM: $VISA_DEBIT_SUM"


# Master Card Sum Credit transactions:
MC_CREDIT_SUM=`gunzip -c  termsimul/transactionFiles/transactions_file*.csv.gz | cut -d, -f3,7,9 | grep 1,100$ | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum;}'`
echo "MC_CREDIT_SUM: $MC_CREDIT_SUM"


# Master Card Sum Debit transactions:
MC_DEBIT_SUM=`gunzip -c  termsimul/transactionFiles/transactions_file*.csv.gz | cut -d, -f3,7,9 | grep 1,200$ | awk -F',' '{sum+=$0;} END{printf "%0.2f\n", sum;}'`
echo "MC_DEBIT_SUM: $MC_DEBIT_SUM"


# Total transaction SUM: 
TOTAL_AMT_SUM=`echo "scale=2; $CREDIT_SUM+$DEBIT_SUM;"| bc`
echo "TOTAL_AMT_SUM: $TOTAL_AMT_SUM"

```


Output from the script execution: 
```
CREDIT_CNT: 922530
DEBIT_CNT: 3686944
LINES: 4609474
VISA_CNT:3963340
VISA_CREDIT_CNT: 793520
VISA_DEBIT_CNT: 3169820
MC_CNT: 646134
MC_CREDIT_CNT: 129010
MC_DEBIT_CNT: 517124
MC_PERC: 14.00
CREDIT_PERC: 20.00
CREDIT_SUM: 30911344.60
AVG_AMT_CREDIT: 33.50
DEBIT_SUM: 84192743.88
AVG_AMT_DEBIT: 22.83
VISA_CREDIT_SUM: 26748358.66
VISA_DEBIT_SUM: 72273166.66
MC_CREDIT_SUM: 4162985.94
MC_DEBIT_SUM: 11919577.22
TOTAL_AMT_SUM: 115104088.48
```