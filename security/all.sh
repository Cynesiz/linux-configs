#!/bin/sh
# Routine for virtual machines 

user="user"
pass=$(uuidgen)
cpass=$(perl -e 'printf("%s\n", crypt($ARGV[0], "password"))' "$pass")
pubkey="pubkey"
sshport="666"
suicide="1"

if [ $user == "user" ]
then
printf "%b" "You forgot to edit the variables!"
exit 1
fi

printf "%b" "\ntmpfs /dev/shm tmpfs defaults,ro 0 0 \n" >> /etc/fstab

printf "%b" "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1\nnet.ipv6.conf.eth0.disable_ipv6 = 1" >> /etc/sysctl.conf

touch /tmp/ipv4
printf "%b" "*filter\n-A INPUT -i lo -j ACCEPT\n-A INPUT ! -i lo -s 127.0.0.0/8 -j REJECT\n-A INPUT -p icmp -m state --state NEW --icmp-type 8 -j ACCEPT\n-A INPUT -p tcp --dport $sshport -m state --state NEW -j ACCEPT\n-A INPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT\n-A INPUT -p tcp --dport 443 -m state --state NEW -j ACCEPT\n-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT\n-A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables_INPUT_denied: " --log-level 7\n-A INPUT -j REJECT\n-A FORWARD -m limit --limit 5/min -j LOG --log-prefix "iptables_FORWARD_denied: " --log-level 7\n-A FORWARD -j REJECT\nCOMMIT" >> /tmp/ipv4
iptables-restore < /tmp/ipv4
iptables -L -vn

mkdir /tmp/bkup
mv /etc/apt/sources.list /tmp/bkup

cat >/etc/apt/sources.list <<EOL
#------------------------------------------------------------------------------#
#                   OFFICIAL DEBIAN REPOS                    
#------------------------------------------------------------------------------#

###### Debian Main Repos
deb http://ftp.us.debian.org/debian/ jessie main contrib 
deb-src http://ftp.us.debian.org/debian/ jessie main 

###### Debian Update Repos
deb http://security.debian.org/ jessie/updates main contrib 
deb http://ftp.us.debian.org/debian/ jessie-proposed-updates main contrib 
deb-src http://security.debian.org/ jessie/updates main contrib 
deb-src http://ftp.us.debian.org/debian/ jessie-proposed-updates main contrib 
EOL

#curl --data "ub%5B0%5D=1&ub%5B1%5D=2&ub_src%5B0%5D=1&uu%5B0%5D=1&uu%5B1%5D=2&uu_src%5B0%5D=1&uu_src%5B1%5D=2&release=$REL&submit=Generate+List&country=us" https://debgen.simplylinux.ch/generate.php |
#sed -n "/DEBIAN OFFICIAL REPOS/,/<\/textarea>/p" | sed '1d;$d' > /etc/apt/sources.list

apt-get update
apt-get -y dist-upgrade --show-upgraded
apt-get -y upgrade --show-upgraded

/usr/sbin/update-rc.d postfix disable
apt-get -y purge postfix
/usr/sbin/update-rc.d ntp disable
apt-get -y purge ntp


apt-get -y install sudo
apt-get -y install ipset
apt-get -y install ip6tables
apt-get -y install fail2ban
apt-get -y install gnupg2
apt-get -y install nano 
apt-get -y install wget 
apt-get -y install htop 
apt-get -y install dnsutils 
apt-get -y install whois 
apt-get -y install acpid 
apt-get -y install unzip 
apt-get -y install tcpdump
apt-get -y install ca-certificates
apt-get -y install --no-install-recommends checksecurity
apt-get -y install --no-install-recommends chkrootkit
# specialty purpose
apt-get -y install sshfs


mkdir /etc/ssh/authorized_keys
touch /etc/ssh/authorized_keys/$user
echo $pubkey > /etc/ssh/authorized_keys/$user
chmod 0700 /etc/ssh/authorized_keys
chmod 0400 /etc/ssh/authorized_keys/$user

useradd -b /home -m -g admin -p $cpass -s /bin/sh $user
chmod -R 0700 /home/$user
chown -R $user:user /home/$user

cat >>/etc/sudoers <<EOL
$user  ALL=(ALL) ALL
EOL

mv /etc/ssh/sshd_Config /tmp/bkup
touch /etc/ssh/sshd_config
printf "%b" "\nPort $sshport\n\nListenAddress 0.0.0.0\n\nKexAlgorithms curve25519-sha256@libssh.org\n\nCiphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr\n\nMACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-ripemd160-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,hmac-ripemd160,umac-128@openssh.com\n\nProtocol 2\n\nHostKey /etc/ssh/ssh_host_ed25519_key\n\nHostKey /etc/ssh/ssh_host_rsa_key\n\n\n# Optional restriction:\n\n# AllowUsers \nAllowUsers $user \n\n# AllowGroups \nAllowGroups admin\n\n#Privilege Separation is turned on for security\nUsePrivilegeSeparation yes\n\n# Lifetime and size of ephemeral version 1 server key\nKeyRegenerationInterval 1800\nServerKeyBits 2048\n\n# Logging\nSyslogFacility AUTH\nLogLevel INFO\n\n# Authentication:\n\nPubkeyAuthentication yes\nAuthorizedKeysFile	/etc/ssh/authorized_keys/%u\n\nPasswordAuthentication no\nLoginGraceTime 120\nPermitRootLogin no\nStrictModes yes\nIgnoreRhosts yes\nRhostsRSAAuthentication no\nHostbasedAuthentication no\nIgnoreUserKnownHosts yes\nPermitEmptyPasswords no\nChallengeResponseAuthentication no\nPasswordAuthentication no\nKerberosAuthentication no\nKerberosGetAFSToken no\nKerberosOrLocalPasswd no\nKerberosTicketCleanup no\nGSSAPIAuthentication no\nGSSAPICleanupCredentials no\nX11Forwarding no\nX11DisplayOffset 10\nPrintMotd no\nPrintLastLog yes\nTCPKeepAlive yes\nUseLogin no\nUsePAM no\n\nAcceptEnv LANG LC_*\n\n#MaxStartups 10:30:60\n#Banner /etc/issue.net\n\nSubsystem sftp /usr/lib/openssh/sftp-server\n" >> /etc/ssh/sshd_config

rm -rf /etc/ssh/ssh_host_*key*
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key < /dev/null
ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key < /dev/null

service sshd restart

chmod -R 0750 /sbin
chmod -R 0750 /bin
chmod -R 0750 /usr/sbin
chmod 700 /usr/bin/who
chmod 700 /usr/bin/w
chmod 700 /usr/bin/locate
chmod 700 /usr/bin/whereis
chmod 700 /usr/bin/vi
chmod 700 /usr/bin/which
chmod 700 /usr/bin/gcc
chmod 700 /usr/bin/make
chmod 700 /usr/bin/apt-get
chmod 700 /usr/bin/aptitude
chown root:admin /bin/su
chmod 04750 /bin/su

mkdir /log
mkdir /log/$HOSTNAME
mount –bind /log/$HOSTNAME /var/log
mount –make-unbindable /log/$HOSTNAME
mount –make-shared /log/$HOSTNAME





