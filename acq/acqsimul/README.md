
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


### How to manually start the tests

From srv1, simulating the CI/CD pipeline: 
```
export LAB_HOSTNAME=localhost
export BUILD_TYPE=DEVELOP
export CODEBUILD_RESOLVED_SOURCE_VERSION=XXX
> ~/RELEASES_DB
curl -X POST -d "Commit Id: ${CODEBUILD_RESOLVED_SOURCE_VERSION} / Type: ${BUILD_TYPE}"$'\n\n' http://${LAB_HOSTNAME}:54167
```

From srv1 just executing the test, without downloading the artifacts: 
```
cd cicdlab
touch /tmp/ENV_LOCKED
~/cicdlab/build/scripts/run_test_cases.sh TEST
```