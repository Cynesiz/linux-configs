
Script is broken, don't use!
exit 1

#!/bin/bash

# Quick install Nginx, Mariadb and PHP-fpm
# Some code taken from  @TobyRyuk TobyRyuk/lemp.sh
#

#sudo chmod +x lemp.sh
#sudo ./lemp.sh

echo "########################################"
echo "Lemp Installer: Nginx, MariaDB & PHP"
echo "########################################"

#echo 'eval $(ssh-agent)' >> ~/.bashrc
#sudo apt-get install language-pack-en-base
#sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

echo "########################################"
echo "Updating repositories..................."
echo "########################################"
sudo apt-get update
sudo apt-get install -y build-essential software-properties-common

echo "########################################"
echo "Installing Nginx........................"
echo "########################################"

# mklement0  @ stackoverflow
# Determine the latest stable version's download URL, assumed to be 
# the first `/download/nginx-*.tar.gz`-like link following the header 
# "Stable version".
latestVer=$(curl -s 'http://nginx.org/en/download.html' | 
   sed 's/</\'$'\n''</g' | sed -n '/>Stable version$/,$ p' | 
   egrep -m1 -o 'nginx-.+\.tar\.gz')

# Download & Extract
mkdir nginx && curl "http://nginx.org/download/${latestVer}" | tar xzC nginx && cd nginx && cd *

./configure --with-http_realip_module
make
sudo make install

echo "########################################"
echo "Installing PHP56......................."
echo "########################################"
sudo apt-get install -y php5 php5-fpm php5-cli php5-mcrypt php5-curl php5-mysql php5-gd php5-intl php5-mbstring php5-dom php-memcached

echo "########################################"
echo "Installing Composer....................."
echo "########################################"

curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

dd if=/dev/zero of=/swapfile bs=1024 count=512k
mkswap /swapfile
swapon /swapfile

# Set Some PHP CLI Settings
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/cli/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/cli/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php5/cli/php.ini
sed -i "s/;date.timezone.*/date.timezone = America\\New_York/" /etc/php5/cli/php.ini

# Setup Some PHP-FPM Options
#ln -s /etc/php5/mods-available/mailparse.ini /etc/php5/fpm/conf.d/20-mailparse.ini

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php5/fpm/php.ini
#sed -i "s/upload_max_filesize = .*/upload_max_filesize = 1M/" /etc/php5/fpm/php.ini
#sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php5/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = America\\New_York/" /etc/php5/fpm/php.ini

php5enmod mcrypt

mkdir /var/www/default
mkdir /var/www/default/htdocs
mkdir /var/www/default/log
chgrp -R www-data /var/www
chmod -R 775 /var/www/default/log

cat >>/etc/nginx/nginx.conf <<EOL
# Default vhost
server {
        listen   80 default_server;

        root /var/www/default/htdocs/;
        index index.php index.html index.htm;

        location / {
             try_files $uri $uri/ /index.php$is_args$args;
        }

        # pass the PHP scripts to FastCGI server listening on /var/run/php5-fpm.sock
        location ~ \.php$ {
                try_files $uri /index.php =404;
                fastcgi_pass unix:/var/run/php5-fpm.sock;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                include fastcgi_params;
        }
}

# Settings for Cloudflare
set_real_ip_from 103.21.244.0/22;
set_real_ip_from 103.22.200.0/22;
set_real_ip_from 103.31.4.0/22;
set_real_ip_from 104.16.0.0/12;
set_real_ip_from 108.162.192.0/18;
set_real_ip_from 131.0.72.0/22;
set_real_ip_from 141.101.64.0/18;
set_real_ip_from 162.158.0.0/15;
set_real_ip_from 172.64.0.0/13;
set_real_ip_from 173.245.48.0/20;
set_real_ip_from 188.114.96.0/20;
set_real_ip_from 190.93.240.0/20;
set_real_ip_from 197.234.240.0/22;
set_real_ip_from 198.41.128.0/17;
set_real_ip_from 199.27.128.0/21;
set_real_ip from 192.168.100.10
set_real_ip_from 2400:cb00::/32;
set_real_ip_from 2606:4700::/32;
set_real_ip_from 2803:f800::/32;
set_real_ip_from 2405:b500::/32;
set_real_ip_from 2405:8100::/32;

# use any of the following two
real_ip_header CF-Connecting-IP;
#real_ip_header X-Forwarded-For;
# Change if you need to
#real_ip_recursive on
EOL

echo "########################################"
echo "Installing MariaDB......................"
echo "########################################"
sudo apt-get install mariadb-server
sudo mysql_install_db
sudo mysql_secure_installation

echo "########################################"
echo "Restarting services....................."
echo "########################################"
sudo service nginx restart
sudo service php5-fpm restart
sudo service mysql restart

echo "All set!\n"

