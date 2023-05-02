clear

export JAVA_HOME=/usr/lib/jvm/jdk-16.0.2

echo Limpeza...

/usr/java/apache-maven-3.8.3/bin/mvn clean

read -n1 -r -p "Press any key to continue..." key

clear

/usr/java/apache-maven-3.8.3/bin/mvn install -DskipTests -Pcli

cd web-app/target/

DATE=$(date '+%d_%m_%Y')
UPDATE_DIR=atu_$DATE
BIN_DIR=$UPDATE_DIR/app/bin

mkdir $UPDATE_DIR
mkdir -p $BIN_DIR

cp web-app-2.0.0.0.jar $BIN_DIR
cd $BIN_DIR
jar xf web-app-2.0.0.0.jar

rm web-app-2.0.0.0.jar
rm BOOT-INF/classes/alpn-boot-8.1.11.v20170118.jar
rm BOOT-INF/classes/application.properties
rm BOOT-INF/classes/keystore.p12
rm -rf BOOT-INF/classes/truststore

find BOOT-INF/lib/ -name "*.jar" -type f -mtime +1 -exec rm -f {} \;

cd ../../../

zip -r $UPDATE_DIR.zip $UPDATE_DIR

ls -la 

read x 

