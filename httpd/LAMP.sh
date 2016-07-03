
Script is broken, don't use!
exit 1

#!/bin/bash
# ******************************************
# Program: VPS SETUP Installation Script
# Developer: Bechir Segni
# Date: 25-02-2016
# Last Updated: 25-02-2016
# ******************************************

echo ""
echo "***********************************************************"
echo "*                Starting VPS setup script                *"
echo "***********************************************************"
echo ""

USER=$(whoami)
if [ "$USER" != "root" ]; then
	echo "You must run this script as \"root\" user!"
	sleep 5
	unset USER
	exit 1
fi

echo "Updating and upgrading the Systeme Before installation ...."
	apt-get update && apt-get upgrade && apt-get autoremove && apt-get clean
echo "install Tools"
	apt-get install unzip wget nano curl -y
	apt-get install build-essential libssl-dev libcurl4-gnutls-dev libexpat1-dev gettext unzip make -y
	apt-get install git -y
echo "Your VPS is Ready to Rock & ROLL"

sleep 1

echo "Setting Up Git"
    git config --global user.name "Moriven"
    git config --global user.email "contact@moriven.net"


echo "Installing ElasticSearch..."
	echo "Installing and Setting Up OpenJDK & Oracle Java..."
	echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list
	echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
	apt-get update && apt-get install oracle-java8-installer
echo "Downloading and Setting up ElasticSearch 2.2"
	cd /opt && wget https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/2.2.0/elasticsearch-2.2.0.deb
	dpkg -i elasticsearch-2.2.0.deb
echo "ElasticSearch Will Start on Boot" 
	update-rc.d elasticsearch defaults
echo "ElasticSearch Ready For Configuration"

sleep 1

echo "Installing NodeJS with NVM"
	curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
	apt-get install -y nodejs
	apt-get install -y build-essential
echo "Node Successfuly installed "

sleep 1


echo "Installing Varnish"
	apt-get install apt-transport-https
	curl https://repo.varnish-cache.org/ubuntu/GPG-key.txt | apt-key add -
	echo "deb https://repo.varnish-cache.org/ubuntu/ trusty varnish-4.0" >> /etc/apt/sources.list.d/varnish-cache.list && apt-get update
	apt-get install varnish
echo "Congratulations, you have successfully installed Varnish You May Now Need To Configure"

sleep 1

if [ "$(lsb_release -is)" == "Ubuntu" ] || [ "$(lsb_release -is)" == "Debian" ]; then
    apt-get -y install mysql-server mysql-client mysql-workbench libmysqld-dev -y;
    apt-get -y install apache2 php5 libapache2-mod-php5 php5-mcrypt phpmyadmin -y;
    chmod 777 -R /var/www/;
    printf "<?php\nphpinfo();\n?>" > /var/www/html/info.php;
    service apache2 restart;
else
    echo "Unsupported Operating System";
fi

sleep 1


if [ "$(which php)" != "" ] && [ "$(which mysql)" != "" ]
then
	echo "Installing Composer"
		php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php
		php -r "if (hash('SHA384', file_get_contents('composer-setup.php')) === 'fd26ce67e3b237fffd5e5544b45b0d92c41a4afe3e3f778e942e43ce6be197b9cdc7c251dcde6e2a52297ea269370680') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); }"
		php composer-setup.php
		php -r "unlink('composer-setup.php');"
		mv composer.phar /usr/local/bin/composer
	echo "Composer Successfully Installed"
fi


sleep 1


if [ "$(which php)" != "" ] && [ "$(which mysql)" != "" ]
then
	echo "Downloading Symfony2 ... "
		cd /var/www && 	wget http://symfony.com/download?v=Symfony_Standard_Vendors_2.8.0.tgz
	echo "Setting up Symfony"
		tar -zxvf download?v=Symfony_Standard_Vendors_2.8.0.tgz
	echo "Setting up Permission"
		tar -zxvf download?v=Symfony_Standard_Vendors_2.8.0.tgz
		chown -R root:www-data app/cache
		chown -R root:www-data app/logs
		chown -R root:www-data app/config/parameters.yml
		chmod -R 775 app/cache
		chmod -R 775 app/logs
		chmod -R 775 app/config/parameters.yml
	echo "You need to do Server Configuration Manually..."
fi


if [ "$(which php)" != "" ] && [ "$(which mysql)" != "" ]
then
echo "Installing Wordpress"
	cd /var/www && wget http://wordpress.org/latest.tar.gz
	tar xzvf latest.tar.gz
	mkdir CpWordpress
	cp ~/wordpress/wp-config-sample.php ~/wordpress/wp-config.php
	rsync -avP /var/www/wordpress/ /var/www/CpWordpress/
	chown www-data:www-data * -R
echo "Wordpress is Ready To Be Configure check https://www.digitalocean.com/community/tutorials/how-to-set-up-multiple-wordpress-sites-on-a-single-ubuntu-vps "
fi


sleep 1


echo "To Configure Symfony https://www.digitalocean.com/community/tutorials/how-to-install-and-get-started-with-symfony-2-on-an-ubuntu-vps"
echo "Configure PHP5 open /etc/php5/cgi/php.ini and uncomment the line cgi.fix_pathinfo=1:"
echo "Now You May Setup ElasticSearch Manually by using updating /etc/elasticsearch/elasticsearch.yml Update the node.name and cluster.name values with your server name (hostname) and the name that the cluster will be associated with. and Start with /etc/init.d/elasticsearch start"
echo "Dont Forget to Configure Varnish"


echo ""
echo "***********************************************************"
echo "*          The setup of your VPS is completed.            *"
echo "***********************************************************"
echo ""
