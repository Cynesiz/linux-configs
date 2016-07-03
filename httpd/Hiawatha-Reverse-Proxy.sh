
Script is broken, don't use!
exit 1

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


# Restart Hiawatha
function restart ()
{
service hiawatha restart
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

echo "Updating System...";

apt update -y;apt upgrade -y;apt dist-upgrade -y; apt install python-pip -y; apt install asciinema;

echo "Installing dependencies...";

apt install libc6-dev libssl-dev dpkg-dev debhelper curl fakeroot libxml2-dev libxslt1-dev -y;

echo "Installing Hiawatha...";

down; dpkg -i hiawatha_*.deb; rm hiawatha_*;

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
mkdir /var/www/default
mkdir /var/www/default/htdocs

echo "Proxy configuration...";end;
while :
do
echo -e -n  "Enter the FQDN for the proxied virtual host or type done : ";
read domain;
[ "${domain}" == 'done' ] && ( echo "Finished Vhost Config"; break; )
echo -e -n  "Enter the host and port to proxy HTTP requests to ex: 127.0.0.1:8080 ";
read destination;
echo -e -n "Enter the log directory location ex: /var/log/${domain} : ";
read logdir;
echo "Creating Local Directories for ${domain}...";
if [[ ! -d ${logdir} ]] && mkdir ${logdir}
echo "Writing Vhost Config for ${domain}...";
cat >/etc/hiawatha/vhosts/${domain}.conf <<EOL
VirtualHost {
  Hostname = ${domain}
  ReverseProxy .* http://${http_dest}
  
  WebsiteRoot = /var/www/default/htdocs
  AccessLogfile = ${logdir}/access.log
  ErrorLogfile = ${logdir}/error.log
  StartFile = index.html
  UseToolkit = common
  PreventXSS = yes
  PreventCSRF = no
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
