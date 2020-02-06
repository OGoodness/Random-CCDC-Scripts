#!/bin/bash

BASEDIR=$(pwd) 						#Set the original install directory, this will be where the config files will be located
CONFIGS="$BASEDIR/Configs"			#This should be the location of the config files you would like to overwrite
ROOTPASS="7L0rpjEgS1iup9OK"

#Make sure there are no mariadb servers currently installed and make sure software-properties-common is present
#
#
#

echo "Makeing sure MariaDB is not installed..."
echo ""
echo ""

apt-get remove mariadb-server  >> /dev/null 2>&1 
apt-get install software-properties-common  >> /dev/null 2>&1 

#Import gpg keys and add apt repo
#
#
#

echo "Adding gpg keys from the key server..."
echo ""
echo ""

apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8  >> /dev/null 2>&1 

echo "Adding the repository to sources.list..."
echo ""
echo ""

add-apt-repository 'deb [arch=amd64] http://mirror.zol.co.zw/mariadb/repo/10.3/ubuntu bionic main' 

echo ""
echo ""
#Install MariaDB
#
#
#
#Set root password
#
#
#


echo 'Making some configuration changes...'
echo ""
echo ""

export DEBIAN_FRONTEND="noninteractive"
debconf-set-selections <<< "mariadb-server mysql-server/root_password password $ROOTPASS"
debconf-set-selections <<< "mariadb-server mysql-server/root_password_again password $ROOTPASS" 


#Update repos and install client/server
#
#
#

echo 'Updating and installing...'
echo ""
echo ""

apt update  >> /dev/null 2>&1 
apt -y install mariadb-server mariadb-client  >> /dev/null 2>&1 

#Securing the installation. Commands are based on mysql_secure_installation
#
#
#

set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable

# Predicate that returns exit status 0 if the database root password
# is set, a nonzero exit status otherwise.
is_mysql_root_password_set() {
  ! mysqladmin --user=root status > /dev/null 2>&1
}

# Predicate that returns exit status 0 if the mysql(1) command is available,
# nonzero exit status otherwise.
is_mysql_command_available() {
  which mysql > /dev/null 2>&1
}

echo "Securing your MariaDB Installation..."
echo ""
echo ""

mysql --user=root -p"7L0rpjEgS1iup9OK" <<EOF
  UPDATE mysql.user SET Password="7L0rpjEgS1iup9OK" WHERE User='root';
  DELETE FROM mysql.user WHERE User='';
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
  DROP DATABASE IF EXISTS test;
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
  FLUSH PRIVILEGES;
  CREATE DATABASE otrs CHARACTER SET utf8 COLLATE utf8_general_ci;
  GRANT ALL PRIVILEGES ON otrs.* TO 'otrs'@'localhost' IDENTIFIED BY 'strongpassword';
  FLUSH PRIVILEGES;
  quit
EOF

echo "All done!  If you've completed all of the above steps, your MariaDB"
echo "installation should now be secure."
echo ""
echo "Thanks for using MariaDB!"
echo ""
echo ""


#Edit the config files

echo "Editing the mariadb.cnf file..."
echo ""
echo ""

cp /etc/mysql/mariadb.cnf /etc/mysql/mariadb.cnf.bak 
mv -f $CONFIGS/mariadb.cnf /etc/mysql/mariadb.cnf

service mysql stop
service mysql start

#Installing the Apache Perl Modules

echo "Installing the Apache Perl Modules..."
echo ""
echo ""

apt-get -y install  apache2 libapache2-mod-perl2  >> /dev/null 2>&1 

#Installing the other necessary Perl Modules

echo "Installing the required Perl Modules..."
apt-get -y install libdatetime-perl libcrypt-eksblowfish-perl libcrypt-ssleay-perl libgd-graph-perl libapache-dbi-perl libsoap-lite-perl libarchive-zip-perl libgd-text-perl libnet-dns-perl libpdf-api2-perl libauthen-ntlm-perl libdbd-odbc-perl libjson-xs-perl libyaml-libyaml-perl libxml-libxml-perl libencode-hanextra-perl libxml-libxslt-perl libpdf-api2-simple-perl libmail-imapclient-perl libtemplate-perl libtext-csv-xs-perl libdbd-pg-perl libapache2-mod-perl2 libtemplate-perl libnet-dns-perl libnet-ldap-perl libio-socket-ssl-perl wget  >> /dev/null 2>&1 
echo ""
echo ""

#Enabling mods and restarting Apache

echo "Enabling the required Perl Modules and restarting Apache..."
a2enmod perl  >> /dev/null 2>&1 
systemctl restart apache2  >> /dev/null 2>&1 
echo ""
echo ""

echo "Creating OTRS Service user..."
useradd -d /opt/otrs -c 'OTRS user' otrs  >> /dev/null 2>&1 
echo ""
echo ""

echo "Adding OTRS Service user to WWW-DATA group..."
usermod -aG www-data otrs  >> /dev/null 2>&1 
echo ""
echo ""


echo "Downloading OTRS..."
wget http://ftp.otrs.org/pub/otrs/otrs-latest.tar.gz  >> /dev/null 2>&1 
echo ""
echo ""

echo "Extracting OTRS..."
tar xvf otrs-latest.tar.gz  >> /dev/null 2>&1 
echo ""
echo ""

#Move the newly created otrs directory to the opt folder
#Make sure there is no other otrs-* directory in the folder you run the script from

echo "Moving OTRS Directory to /opt..."
mv $(pwd)/otrs-6* /opt/otrs  >> /dev/null 2>&1 
echo ""
echo ""

echo "Creating the OTRS Config File..."
cp /opt/otrs/Kernel/Config.pm.dist /opt/otrs/Kernel/Config.pm 
echo ""
echo ""

echo "Enabling the MySQL Perl module..."
mv -f $CONFIGS/apache2-perl-startup.pl /opt/otrs/scripts/apache2-perl-startup.pl
echo ""
echo ""

echo "Setting Permissions for OTRS Directory..."
/opt/otrs/bin/otrs.SetPermissions.pl --web-group=www-data
echo ""
echo ""

echo "Configuring OTRS Apache Virtual Host..."
ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/sites-enabled/otrs.conf
echo ""
echo ""

echo "Confirm all PERL Modules are available..."
perl -cw /opt/otrs/bin/cgi-bin/index.pl
perl -cw /opt/otrs/bin/cgi-bin/customer.pl
perl -cw /opt/otrs/bin/otrs.Console.pl

echo ""

echo "Restarting Apache..."
systemctl restart apache2
echo ""
echo ""

echo "Opening the Firewall on port 80..."
ufw allow 80
echo ""
echo ""

#Download the logo
#wget https://www.dhs.gov/sites/default/files/images/CISA/18_1116_CISA_wordmark.png
#mv 18_1116_CISA_wordmark.png /opt/otrs/var/httpd/htdocs/skins/Agent/default/img/CISA.png

echo "Here is the root password for the otrs database."
echo "Please save for your records: '$ROOTPASS' "
echo "The default username is: otrs"
echo "The default password is: strongpassword"
echo ""
echo "You should now access the web interface to finish configuration."
echo "http://server-ip/otrs/installer.pl"
echo ""
echo "Please follow the following steps:"
echo "Step 1: Accept License Agreement"
echo "Step 2: Configure database settings, choose Use existing database – MySQL."

echo "******************************************************************************"
echo "*                                                                            *"
echo "* Then provide access details:                                               *"
echo "*                                                                            *"
echo "*       User: otrs                                                           *"
echo "*       Password: strongpassword                                             *"
echo "*       Host: 127.0.0.1                                                      *"
echo "*       Database Name: otrs                                                  *"                                                         
echo "*                                                                            *"
echo "******************************************************************************"


echo "Step 3: Skip Email settings for now"
echo "Step 4: Save the newly created username and password. Click Finish."
echo "Step 5: Login using the URL Provided."

echo "******************************************************************************"
echo "*                                                                            *"
echo "*Step 6: After logging in, start the OTRS Daemon using the following commands*"
echo "*                                                                            *"
echo '*su - otrs -c "/opt/otrs/bin/otrs.Daemon.pl start                            *"'
echo '*su - otrs -c "/opt/otrs/bin/Cron.sh start                                   *"'
echo "*                                                                            *"
echo "******************************************************************************"
echo ""


