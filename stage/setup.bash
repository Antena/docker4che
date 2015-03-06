#!/bin/sh
set -v

# Install dependencies
apt-get update
apt-get upgrade -y
apt-get install -y curl zip postgresql postgresql-contrib openjdk-6-jdk

# Make the dcm4chee home dir
DCM4CHEE_HOME=/var/local/dcm4chee
DCM4CHEE_VERSION=2.17.1
mkdir -p $DCM4CHEE_HOME
cd $DCM4CHEE_HOME

# Download the binary package for DCM4CHEE
curl -G http://ufpr.dl.sourceforge.net/project/dcm4che/dcm4chee/$DCM4CHEE_VERSION/dcm4chee-$DCM4CHEE_VERSION-psql.zip > /stage/dcm4chee-$DCM4CHEE_VERSION-psql.zip
unzip -q /stage/dcm4chee-$DCM4CHEE_VERSION-psql.zip
DCM_DIR=$DCM4CHEE_HOME/dcm4chee-$DCM4CHEE_VERSION-psql

# Download the binary package for JBoss
curl -G http://colocrossing.dl.sourceforge.net/project/jboss/JBoss/JBoss-4.2.3.GA/jboss-4.2.3.GA-jdk6.zip > /stage/jboss-4.2.3.GA-jdk6.zip
unzip -q /stage/jboss-4.2.3.GA-jdk6.zip
JBOSS_DIR=$DCM4CHEE_HOME/jboss-4.2.3.GA

# Download the Audit Record Repository (ARR) package
curl -G http://ufpr.dl.sourceforge.net/project/dcm4che/dcm4chee-arr/3.0.11/dcm4chee-arr-3.0.11-psql.zip > /stage/dcm4chee-arr-3.0.11-psql.zip
unzip -q /stage/dcm4chee-arr-3.0.11-psql.zip
ARR_DIR=$DCM4CHEE_HOME/dcm4chee-arr-3.0.11-psql

# Copy files from JBoss to dcm4chee
$DCM_DIR/bin/install_jboss.sh jboss-4.2.3.GA > /dev/null

# Copy files from the Audit Record Repository (ARR) to dcm4chee
$DCM_DIR/bin/install_arr.sh dcm4chee-arr-3.0.11-psql > /dev/null

# Setup Postgres
PGDATA=/etc/postgresql/9.3/main
PGUSER=postgres
cp /stage/pg_hba.conf $PGDATA/
/etc/init.d/postgresql restart
sleep 5s

# Setup PACS DB
createdb --username=$PGUSER pacsdb
psql --username=$PGUSER pacsdb -f $DCM_DIR/sql/create.psql

# Setup Audit DB
createdb --username=$PGUSER arrdb
psql --username=$PGUSER pacsdb -f $ARR_DIR/sql/dcm4chee-arr-psql.ddl

# Shutdown Postgres
/etc/init.d/postgresql stop
sleep 5s

# Patch the JPEGImageEncoder issue for the WADO service
sed -e "s/value=\"com.sun.media.imageioimpl.plugins.jpeg.CLibJPEGImageWriter\"/value=\"com.sun.image.codec.jpeg.JPEGImageEncoder\"/g" < $DCM_DIR/server/default/conf/xmdesc/dcm4chee-wado-xmbean.xml > dcm4chee-wado-xmbean.xml
mv dcm4chee-wado-xmbean.xml $DCM_DIR/server/default/conf/xmdesc/dcm4chee-wado-xmbean.xml

# Update environment variables
echo "\
JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64\n\
PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"\n\
" > /etc/environment