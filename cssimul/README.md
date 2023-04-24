
# Card Scheme simulator 
Based on spring boot and Netty to simulate a single plain socket asynchronous communication with a MIP or a VAP


Basic test:
```
echo -n 00083131303038383838 | xxd -p -r | nc localhost 4900 | xxd -p
```
