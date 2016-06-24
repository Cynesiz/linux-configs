#!/bin/bash
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
function enter ()
 {
  echo ""
  read -sn 1 -p "Press any key to continue..."
  clear
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

# Setting wordpress vhost [s]

function wordpress_vhost()
{
 echo -e "\e[31m\n$up This script will remove any directory with name wordpress, take care about that.\nControl + C if you want to check then start script again.\e[0m"
 sleep 5
 echo -e  -n "\n$up Set site/vhost order/remove number(example 1-10): "
 read number
 echo -e -n "\n$up Enter domain name or your server IP: "
 read domain
 echo -e -n "\n$up Enter site folder (example /var/www/hiawatha/wordpress): "
 read root
 echo -e -n "\n$up Enter site default page (index.php or index.html): "
 read index
 echo -e "\n#${number}\nVirtualHost {\n\tHostname = ${domain} \n\tWebsiteRoot = ${root}\n\tStartFile = ${index} #Use index.php or index.html\n\t#AccessLogfile = ${root}/access.log\n\t#ErrorLogfile = ${root}/error.log\n\tTimeForCGI = 5\n\tUseFastCGI = PHP5\n\tUseToolKit = wordpress\n}\n
#${number}\nUrlToolkit {\nToolkitID = wordpress\nRequestURI exists Return\nMatch .*\?(.*) Rewrite /index.php?$1\nMatch .* Rewrite /index.php\n}" >> $config
mkdir -p $root
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

 # Removing wordpress installation

 function rem_wordpress()
 {
 echo -n "\n\t$up Type Wordpress path directory (ex./var/www/hiawatha/wordpress):"
 read word_path
 rm -rf $word_path
   echo -e -n "\n\t$up Enter your mysql user name: "
   read user
   echo -e -n "\n\t$up Type mysql password(you can't see your password): "
   stty_orig=`stty -g`
   stty -echo
   read pass
   stty $stty_orig
   echo ""
   echo -e -n "\n\t$up Type wordpress database name: "
   read db_name
   mysql -u $user -p$pass -e "drop database $db_name"
   service mysql restart
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

 # Simple function yes and no when user start installation of phpmyadmin
 function yes_no ()
 {
   echo -e "\n$up \e[40;38;5;82mPHPMYADMIN INSTALLATION \e[0m\n"
   read -p "Install phpMyAdmin (y/n)? " choice
   case "$choice" in
   y|Y ) phpmyadmin;admin_hiawatha;where_phpmyadmin;;
   n|N ) selection;;
   * ) echo -e "$up Wrong answer. Don't worry you can start phpMyadmin installation when you are ready";;
 esac
 }

 # Need to be set for vhost needs

 function where_phpmyadmin ()
 {
   echo -e -n "\n$up Type your main site path directory (ex./var/www/hiawatha/wordpress): "
   read phpadmin
   ln -s /usr/share/phpmyadmin $phpadmin
 }

 # Get last version from server and install

 function phpmyadmin ()
 {
apt install phpmyadmin -y
 }

 function admin_hiawatha ()
 {
   sed -i '/#Use index.php or index.html/s/$/\n\tAlias = \/phpmyadmin:\/usr\/share\/phpmyadmin/' $config
   restart
   enter
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

 # Removing protection rule

 function protect_remove ()
 {
 echo -e -n "\n$up Enter remove number: "
 read n
 for i in "${n[@]}"
 do sed -i "/#${n}\0/,/} /d" $config
 done
 sed -i 's/ $//' $config
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
port     = sftp,$port
filter   = sshd
logpath  = /var/log/auth.log
findtime = 300
maxretry = 3
bantime = 86400
EOF
  echo""
  service fail2ban restart
 }

 function fail2_remove()
 {
   rm /etc/fail2ban/jail.local
   apt --purge remove fail2ban -y
 }

 # Menu
 function print_menu()
 {
   banner
   echo ""
   echo "[1] - system update, upgrade and dist-upgrade."
   echo "[2] - install required dependencies for Hiawatha."
   echo "[3] - install PHP5 and PHP5 modules."
   echo "[4] - installation of MariaDB 10.0."
   echo "[5] - secure MariaDB installation."
   echo "[6] - install Hiawatha Webserver."
   echo "[7] - set VPS/SERVER time zone."
   echo -e "\n\e[40;38;5;82m SETTING HIAWATHA \e[30;48;5;82m WEB SERVER \e[0m \n"
   echo "[8] - setting PHP-FPM (FastCGI)."
   echo "[9] - add new VHOST (ex. site order number, yoursite.com, /var/www, index.php)"
   echo "[10] - install Wordpress (don't run option 9 if you want to do this)."
   echo "[11] - remove VHOST."
   echo "[12] - install phpMyadmin (run only after setting first vhost)."
   echo "[13] - remove phpMyadmin."
   echo "[14] - remove Wordpress installation."
   echo -e "\n\e[40;38;5;82m HIAWATHA \e[30;48;5;82m SECURITY \e[0m \n"
   echo "[15] - protect site directory."
   echo "[16] - remove directory protection."
   echo "[17] - ban clients who misbehave (basic DDOS protection)."
   echo "[18] - install fail2ban and protect SSH and SFTP."
   echo "[19] - remove fail2ban and settings."
   echo ""
   echo "[0] - exit program."
   echo ""
   echo -e -n "$up Enter selection: "
 }

 selection=
 until [ "$selection" = "0" ]; do
   print_menu
   read selection
   echo ""
   case $selection in

   1 ) apt update -y;apt upgrade -y;apt dist-upgrade -y; apt install python-pip -y; apt install asciinema;clear;;
   2 ) apt install libc6-dev libssl-dev dpkg-dev debhelper curl fakeroot libxml2-dev libxslt1-dev -y;clear;;
   3 ) apt install php5-cgi php5 php5-cli php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl php5-xcache apache2-utils php5-fpm -y;enter;;
   4 ) apt install python-software-properties -y;mariadb;clear;;
   5 ) mariadb_secure;enter;clear ;;
   6 ) down; dpkg -i hiawatha_*.deb; rm hiawatha_*;enter ;;
   7 ) dpkg-reconfigure tzdata; enter; echo "We are done.It was cool? NO :)";enter ;;
   8 ) echo -e $info;sleep 3;cp $config $config\.backup;x=( 57 58 59 60 61 );for i in "${x[@]}";do sed -i "${i}s/^#//" $config;done;sed -i s'/\#CGIhandler\ =\ \/usr\/bin\/php\-cgi\:php/CGIhandler\ = \/usr\/bin\/php\-cgi\:php/' $config;sed -i s#"$connect1"#"$connect2"#g $config;service php5-fpm restart; enter ;;
   9 ) echo -e -n "\n$up Set site/vhost remove number(example 1-10): ";read number; echo -e -n "\n$up Enter domain name or your server IP: ";read domain;echo -e -n "\n$up Enter site folder (example /var/www/hiawatha): ";read root;echo -e -n "\n$up Enter site default page (index.php or index.html): ";read index;echo -e "\n#${number}\nVirtualHost {\n\tHostname = ${domain} \n\tWebsiteRoot = ${root}\n\tStartFile = ${index} #Use index.php or index.html\n\t#AccessLogfile = ${root}/access.log\n\t#ErrorLogfile = ${root}/error.log\n\tTimeForCGI = 20\n\tUseFastCGI = PHP5\n}" >> $config;enter ;;
   10 ) wordpress_vhost;wordpress;set_mysql;echo "";restart;echo "";service php5-fpm restart;echo -e "\e[31m\n$up Open your browser with your domain or ip and start wordpress installation.\nIf something goes wrong check your settings (/etc/hiawatha/hiawatha.conf)\e[0m";sleep 3;yes_no ;;
   11 ) echo -e -n "\n$up Enter site/vhost remove number: " ;read n; for i in "${n[@]}";do sed -i "/#${n}/,/} /d" $config;done;sed -i '$d' $config;enter ;;
   12 ) phpmyadmin;admin_hiawatha;where_phpmyadmin; ;;
   13 ) apt remove phpmyadmin;rem=$(find / -type d -name phpmyadmin); rm -rf $rem;enter;;
   14 ) rem_wordpress;enter ;;
   15 ) echo -e "\n$up\e[31m If you want to protect directory from public access use this option\e[0m";protect ;;
   16 ) protect_remove ;;
   17 ) x=( 40 41 42 43 44 );for i in "${x[@]}";do sed -i "${i}s/^#//" $config;done; clear;;
   18 ) fail2; enter ;;
   19 ) fail2_remove;clear ;;
   0 ) exit ;;
   * ) echo -e "$up Please enter 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, ,13, 14, 15, 16, 17, 18, 19 or 0"
   esac
 done
