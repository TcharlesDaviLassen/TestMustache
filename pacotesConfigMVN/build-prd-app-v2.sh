clear

export JAVA_HOME=/usr/lib/jvm/java-16-openjdk-amd64

echo Limpeza...

/usr/java/apache-maven-3.8.3/bin/mvn clean

read -n1 -r -p "Press any key to continue..." key

clear

/usr/java/apache-maven-3.8.3/bin/mvn install -DskipTests -Pprd-app