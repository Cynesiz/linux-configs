#!/bin/bash
# LIMP Auto-Install Hacked together by Riemannian
# This script will help you to set Hiawatha Server.
# Tested on Devuan 8 32/64bit. Debian Jessie supported as well.
# Script author ZEROF <zerof at backbox dot org>
# If you like Linux and security join http://backbox.org
# Script version 0.6c
# This script is distributed under a DO WHAT THE F*** YOU WANT TO PUBLIC LICENSE.
# http://www.wtfpl.net/txt/copying/
clear
function banner ()
{
 echo ""
 echo -e "╦ ╦┬┌─┐┬ ┬┌─┐┌┬┐┬ ┬┌─┐   ╔═╗╦ ╦╔═╗   ╔═╗╔═╗╔╦╗   ╔╦╗┌─┐┬─┐┬┌─┐╔╦╗╔╗ "
 echo -e "╠═╣│├─┤│││├─┤ │ ├─┤├─┤───╠═╝╠═╣╠═╝───╠╣ ╠═╝║║║───║║║├─┤├┬┘│├─┤ ║║╠╩╗"
 echo -e "╩ ╩┴┴ ┴└┴┘┴ ┴ ┴ ┴ ┴┴ ┴   ╩  ╩ ╩╩     ╚  ╩  ╩ ╩   ╩ ╩┴ ┴┴└─┴┴ ┴═╩╝╚═╝"
}

# Vars
config="/etc/hiawatha/hiawatha.conf"
connect1="ConnectTo = /var/lib/hiawatha/php-fcgi.sock"
connect2="ConnectTo = /var/run/php5-fpm.sock"
info="[!]This is only for fresh installed servers, script don't check if you made changes on your system.\n[!]If something goes wrong, you can find hiawatha.conf.backup in /etc/hiawatha/."
up="\033[1;33m[!]\e[0m"


#User check. Must be r00t

if [ $USER != 'root' ]; then
  echo "[!]Are you root? NO. Then try again."
  exit
fi

# End function
function end ()
 {
  echo "\n-----------------------------------------------------------\n"
}

#Check for system versin and egrep last package from tuxhelp
download_deb() {
	wget "https://files.tuxhelp.org/hiawatha/$(wget -O- https://files.tuxhelp.org/hiawatha | egrep -o "hiawatha_[0-9\.]+_$1.deb" | sort -V | sort -V | tail -1)"
}

#Download
down() {
if [ "$(getconf LONG_BIT)" = "64" ]; then
    download_deb amd64
else
    download_deb i386
fi
}

# Just to be sure that menu will work around
$selection

# Restart Hiawatha
function restart ()
{
service hiawatha restart
}

# Install MariaDB

function mariadb ()
{
apt install mariadb-server -y
}

function mariadb_secure ()
{
mysql_secure_installation
}

 # wget last version from WP site

  function wordpress ()
 {
 if [ -d "$wordpress)" ]; then
   rm -rf wordpress
   else
   echo -e "\n$up We are going to install your Wordpress site.\n"
 enter
 fi
   wget http://wordpress.org/latest.tar.gz
   tar -xzf latest.tar.gz
   echo -e -n "$up Your wordpress vhost directory (ex./var/www/hiawatha/wordpress): "
   read path
   cp -r wordpress ${path}
   chown -R www-data:www-data ${path}
   rm latest.tar.gz
   rm -rf wordpress
 }


 # Setting MySql server details

 function set_mysql ()
 {
   echo -e -n "\n\t$up Enter your mysql user name: "
   read user
   echo -e -n "\n\t$up Type mysql password(you can't see your password): "
   stty_orig=`stty -g`
   stty -echo
   read pass
   stty $stty_orig
   echo ""
   echo -e -n "\n\t$up Type database name: "
   read db_name
   mysql -u $user -p$pass -e "create database $db_name"
   service mysql remove
 }

 

 # Hiawatha function to protect folders and file

 function protect ()
 {
 echo -e -n "\n$up Enter order number for removing rules in the future(ex 1,2): "
 read number
 echo -e -n "\n$up Enter path directory you want to protect (example /var/www/hiawatha/): "
 read directory
 echo -e "\n#${number}0\nDirectory {\nPath = $directory\nAccessList = Deny All\n}" >> /etc/hiawatha/hiawatha.conf
 restart
 }


 function fail2 ()
 {
   apt install fail2ban -y
   service fail2ban restart
   cd /etc/fail2ban
   echo ""
   echo -e "\e[30;48;5;82m We are going to protect your server SSH and SFTP with fail2ban. \e[0m \n"
   sleep 2
   echo -e "\e[30;48;5;82m  For that we will need information about port your are using for SSH. \e[0m \n"
   sleep 2
   echo -ne "\e[30;48;5;82m You SSH port is: \e[0m"
   read port
   cat <<EOF > "/etc/fail2ban/jail.local"
[ssh]
enabled  = true
port     = sftp,22
filter   = sshd
logpath  = /var/log/auth.log
findtime = 300
maxretry = 3
bantime = 86400
EOF
  echo""
  service fail2ban restart
 }


banner;

echo "LIMP Installation Started..."
echo "";
echo "Setting time zone...";

dpkg-reconfigure tzdata;

echo "Updating System...";

apt update -y;apt upgrade -y;apt dist-upgrade -y; apt install python-pip -y; apt install asciinema;

echo "Installing dependencies...";

apt install libc6-dev libssl-dev dpkg-dev debhelper curl fakeroot libxml2-dev libxslt1-dev -y;

echo "Installing PHP...";

apt install php5-cgi php5 php5-cli php5-mysql php5-curl php5-gd php5-intl php-pear php5-mcrypt php5-memcache php5-tidy php5-xmlrpc php5-xsl php5-xcache apache2-utils php5-fpm -y;

echo "Installing MariaDB...";

apt install python-software-properties -y;mariadb;

echo "Securing MariaDB...";

mariadb_secure;

echo "Installing Hiawatha...";

down; dpkg -i hiawatha_*.deb; rm hiawatha_*;

echo "Configuring Hiawatha for PHP...";

sleep 3;cp $config $config\.backup;x=( 57 58 59 60 61 );for i in "${x[@]}";do sed -i "${i}s/^#//" $config;done;sed -i s'/\#CGIhandler\ =\ \/usr\/bin\/php\-cgi\:php/CGIhandler\ = \/usr\/bin\/php\-cgi\:php/' $config;sed -i s#"$connect1"#"$connect2"#g $config;service php5-fpm restart;

echo "Securing Hiawatha Installation...";

x=( 40 41 42 43 44 );for i in "${x[@]}";do sed -i "${i}s/^#//" $config;done; 

cat >$config <<EOL
BanOnDeniedBody = 300
BanOnSQLi = 300
BanOnFlooding = 90/1:300
BanlistMask = deny 127.0.0.1
BanOnInvalidURL = 300
BanOnWrongPassword = 3:300
ChallengeClient = 70,httpheader,300
RebanDuringBan = yes
LogFormat = extended
MinTLSversion = 1.2
ServerString = Sun ONE Web Server 6.1

Include /etc/hiawatha/vhosts/

# URL TOOLKIT
# This URL toolkit rule was made for the Banshee PHP framework, which
# can be downloaded from http://www.hiawatha-webserver.org/banshee
#
UrlToolkit {
  ToolkitID = common
  Do Call scanners
  Do Call vulnfs
  RequestURI isfile Return
  Match ^/(css|files|images|js|assets|static)($|/) Return
  Match ^/(favicon.ico|robots.txt|sitemap.xml)$ Return
  Match .*\?(.*) Rewrite /index.php?$1
  Match .* Rewrite /index.php
}

UrlToolkit {
  ToolkitID = vulnfs
  Header * \(\)\s*\{ Ban 900   # Shellshock
  MatchCI ^/(crawler|admin|wp-admin|dashboard|pma|myadmin|phpmyadmin|cgi-bin)($|/) Ban 900 
  MatchCI ^/(xmlrpc.php|phpinfo.php|.htaccess|.htpasswd|wp-config.php|readme.html|README.me|changelog.txt|CHANGELOG|LICENSE|license.txt)$ Ban 900 
}

UrlToolkit {
  ToolkitID = scanners
  Header User-Agent ^w3af.sourceforge.net Ban 900
  Header User-Agent ^dirbuster Ban 900
  Header User-Agent ^nikto Ban 900
  Header User-Agent ^sqlmap Ban 900
  Header User-Agent ^fimap Ban 900
  Header User-Agent ^nessus Ban 900
  Header User-Agent ^Nessus Ban 900
  Header User-Agent ^whatweb Ban 900
  Header User-Agent ^Openvas Ban 900
  Header User-Agent ^jbrofuzz Ban 900
  Header User-Agent ^libwhisker Ban 900
  Header User-Agent ^webshag Ban 900
  Header User-Agent ^Morfeus Ban 900
  Header User-Agent ^Fucking Ban 900
  Header User-Agent ^Scanner Ban 900
  Header User-Agent ^Aboundex Ban 900
  Header User-Agent ^AlphaServer Ban 900
  Header User-Agent ^Indy Ban 900
  Header User-Agent ^ZmEu Ban 900
  Header User-Agent ^social Ban 900
  Header User-Agent ^Zollard Ban 900
  Header User-Agent ^CLR Ban 900
  Header User-Agent ^Camino Ban 900
  Header User-Agent ^Nmap Ban 900
  Header * ^WVS Ban 900
  Header User-Agent ^Python-httplib Ban 900
  Header User-Agent ^Python-requests Ban 900
  Header User-Agent ^masscan Ban 900
  Header User-Agent ^Java Ban 900
  Header User-Agent ^Nutch Ban 900
  Header User-Agent ^Who.is Ban 900
  Header User-Agent ^immoral Ban 900
  Header User-Agent ^crawler Ban 900
  Header User-Agent ^NetShelter Ban 900
  Header User-Agent ^Application Ban 900
  Header User-Agent ^Validator.nu/LV Ban 900
  Header * ^ssdp Ban 900
  Header User-Agent ^Arachni Ban 900
  Header User-Agent ^Spider-Pig Ban 900
  Header User-Agent ^tinfoilsecurity Ban 900
  Header User-Agent ^@ Ban 900
  Header User-Agent ^shellshock-scan Ban 900
  Header User-Agent ^Vega Ban 900
  Header * ^\(\)\s*\{ Ban 900
  Header * ^uname Ban 900
  Header * ^whoami Ban 900
  Header User-Agent ^friendly-scanner Ban 900
  Header * ^mxmail.netease.com Ban 900
  Header * ^muieblackcat Ban 900
  Header User-Agent ^BOT\sfor\sJCE Ban 900
}
EOL

mkdir /etc/hiawatha/ssl;
mkdir /etc/hiawatha/vhosts;

echo "Prompting to v-host config...";end;
while :
do
echo -e -n  "Enter a domain, IP or type done if you're finished: ";
read domain;
[ "${domain}" == 'done' ] && ( echo "Finished Vhost Config"; break; )
echo -e -n  "Enter site folder (example /var/www/hiawatha): ";
read root;
echo -e -n "Enter site default page (index.php or index.html): ";
read index;
echo "Creating Directories for ${domain}...";
mkdir ${root}
mkdir ${root}/htdocs;
mkdir ${root}/log;
echo "Writing Vhost Config for ${domain}...";
cat >/etc/hiawatha/vhosts/${domain}.conf <<EOL
#${number}
VirtualHost {
  Hostname = ${domain}
  WebsiteRoot = ${root}/htdocs
  AccessLogfile = ${root}/log/access.log
  ErrorLogfile = ${root}/log/error.log
  StartFile = ${index}
  TimeForCGI = 20
  UseFastCGI = PHP5
  ExecuteCGI = yes

  UseToolkit = common

  PreventXSS = yes
  PreventCSRF = yes
  PreventSQLi = yes

  RandomHeader = 250

  CustomHeader X-Powered-By: Java Servlet 2.3
  CustomHeader X-Frame-Options "SAMEORIGIN" always;
  CustomHeader X-Xss-Protection "1; mode=block" always;
  CustomHeader X-Content-Type-Options "nosniff" always;
  CustomHeader Content-Security-Policy "default-src http: data: 'unsafe-inline' 'unsafe-eval'" always;
}
EOL
done
echo "Installing Fail2Ban...";
fail2; end ;
echo "Finished."
echo ""
exit 0
