clear

export JAVA_HOME=/usr/java/jdk-16.0.2

echo Limpeza...

/usr/java/apache-maven-3.8.1/bin/mvn clean

read -n1 -r -p "Press any key to continue..." key

clear

/usr/java/apache-maven-3.8.1/bin/mvn install -DskipTests -Pcli

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

cd $UPDATE_DIR

zip -P Z5klMoPQ2345 -r ../atu.zip *

cd ..

echo $(md5sum atu.zip | awk '{print $1}') > hash

ls -la 

read -n1 -r -p "Fazer upload para FTP(s/S)?" enviarFtp

if [[ "$enviarFtp" == "S" || "$enviarFtp" == "s" ]]; then
    echo
    echo
    ../../upload-ftp.sh
else
    echo
    echo
    echo "Arquivos não enviados ao ftp..."
fi

read y

