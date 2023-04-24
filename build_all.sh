#!/usr/bin/bash

[ ! -d build ] && mkdir build

cd acq && gradle build && cd -
cp -p acq/acqsimul/build/libs/acqsimul-*-SNAPSHOT.jar build/acqsimul-db0.jar
cp -p acq/acqrestproxy/build/libs/acqrestproxy-*-SNAPSHOT.jar build/
cp -p acq/acqcsproxy/build/libs/acqcsproxy-*-SNAPSHOT.jar build/
cp -p acq/acqsimul/build/libs/acqsimul-*-SNAPSHOT.jar build/acqsimul-current.jar
cd acq && gradle clean && cd -


sed -i 's/acqsimul_db0/acqsimul_db1/g' acq/acqsimul/build.gradle
sed -i 's/acqsimul_db0/acqsimul_db1/g' acq/settings.gradle
cd acq && gradle build && cd -
cp -p acq/acqsimul/build/libs/acqsimul-*-SNAPSHOT.jar build/acqsimul-db1.jar
cd acq && gradle clean && cd -


sed -i 's/acqsimul_db1/acqsimul_db1_devops0/g' acq/acqsimul/build.gradle
sed -i 's/acqsimul_db1/acqsimul_db1_devops0/g' acq/settings.gradle
cd acq/acqsimul && gradle clean && gradle build && cd -
cp -p acq/acqsimul/build/libs/acqsimul-*-SNAPSHOT.jar build/acqsimul-db1-devops0.jar


sed -i 's/acqsimul_db1_devops0/acqsimul_db1_devops1/g' acq/acqsimul/build.gradle
sed -i 's/acqsimul_db1_devops0/acqsimul_db1_devops1/g' acq/settings.gradle
cd acq/acqsimul && gradle clean && gradle build && cd -
cp -p acq/acqsimul/build/libs/acqsimul-*-SNAPSHOT.jar build/acqsimul-db1-devops1.jar


sed -i 's/acqsimul_db1_devops1/acqsimul_db2/g' acq/acqsimul/build.gradle
sed -i 's/acqsimul_db1_devops1/acqsimul_db2/g' acq/settings.gradle
cd acq && gradle build && cd -
cp -p acq/acqsimul/build/libs/acqsimul-*-SNAPSHOT.jar build/acqsimul-db2.jar
cd acq && gradle clean && cd -


sed -i 's/acqsimul_db2/acqsimul_db2_devops0/g' acq/acqsimul/build.gradle
sed -i 's/acqsimul_db2/acqsimul_db2_devops0/g' acq/settings.gradle
cd acq/acqsimul && gradle clean && gradle build && cd -
cp -p acq/acqsimul/build/libs/acqsimul-*-SNAPSHOT.jar build/acqsimul-db2-devops0.jar


sed -i 's/acqsimul_db2_devops0/acqsimul_db2_devops1/g' acq/acqsimul/build.gradle
sed -i 's/acqsimul_db2_devops0/acqsimul_db2_devops1/g' acq/settings.gradle
cd acq/acqsimul && gradle clean && gradle build && cd -
cp -p acq/acqsimul/build/libs/acqsimul-*-SNAPSHOT.jar build/acqsimul-db2-devops1.jar


sed -i 's/acqsimul_db2_devops1/acqsimul_db2_devops2/g' acq/acqsimul/build.gradle
sed -i 's/acqsimul_db2_devops1/acqsimul_db2_devops2/g' acq/settings.gradle
cd acq/acqsimul && gradle clean && gradle build && cd -
cp -p acq/acqsimul/build/libs/acqsimul-*-SNAPSHOT.jar build/acqsimul-db2-devops2.jar

    
sed -i 's/acqsimul_db2_devops2/acqsimul_db3/g' acq/acqsimul/build.gradle
sed -i 's/acqsimul_db2_devops2/acqsimul_db3/g' acq/settings.gradle
cd acq && gradle build && cd -
cp -p acq/acqsimul/build/libs/acqsimul-*-SNAPSHOT.jar build/acqsimul-db3.jar
cd acq && gradle clean && cd -


sed -i 's/acqsimul_db3/acqsimul_db3_devops0/g' acq/acqsimul/build.gradle
sed -i 's/acqsimul_db3/acqsimul_db3_devops0/g' acq/settings.gradle
cd acq/acqsimul && gradle clean && gradle build && cd -
cp -p acq/acqsimul/build/libs/acqsimul-*-SNAPSHOT.jar build/acqsimul-db3-devops0.jar

sed -i 's/acqsimul_db3_devops0/acqsimul_db3_devops1/g' acq/acqsimul/build.gradle
sed -i 's/acqsimul_db3_devops0/acqsimul_db3_devops1/g' acq/settings.gradle
cd acq/acqsimul && gradle clean && gradle build && cd -
cp -p acq/acqsimul/build/libs/acqsimul-*-SNAPSHOT.jar build/acqsimul-db3-devops1.jar

cd termsimul && gradle build && cd -
cp -p termsimul/build/libs/termsimul-*-SNAPSHOT.jar build/

cd cssimul && gradle build && cd -
cp -p cssimul/build/libs/cssimul-*-SNAPSHOT.jar build/