
# Acquirer Simulator

Contains the source code based on Java Spring Boot

## How to build

### install build environment
The following procedure is for Ubuntu Linux 20.04 LTS (focal)

* Install java 17 (openjdk 17)
```
sudo apt install -y openjdk-17-jdk openjdk-17-jre
```
* Install Gradle 7.4.1
```
wget https://services.gradle.org/distributions/gradle-7.4.1-bin.zip
sudo mkdir /opt/gradle
sudo unzip -d /opt/gradle gradle-7.4.1-bin.zip
echo 'export PATH=$PATH:/opt/gradle/gradle-7.4.1/bin' >> ~/.profile
```


### build commands
gradle build



