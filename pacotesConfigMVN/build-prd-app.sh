clear

export JAVA_HOME=/usr/java/jdk-16.0.2

echo Limpeza...

/usr/java/apache-maven-3.8.1/bin/mvn clean

read -n1 -r -p "Press any key to continue..." key

clear

/usr/java/apache-maven-3.8.1/bin/mvn install -DskipTests -Pprd-app