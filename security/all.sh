#!/bin/bash
# Routine for virtual machines 
function randalph () 
{
len=$1
if [ -z "$1" ]
then
len=16
fi
cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w "$len" | head -n 1
}

function randnumb () 
{
len=$1
if [ -z "$1" ]
then
len=16
fi
cat /dev/urandom | tr -dc '0-9' | fold -w "$len" | head -n 1
}

function randalphnum () 
{
len=$1
if [ -z "$1" ]
then
len=16
fi
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w "$len" | head -n 1
}

user="user"
pubkey="ssh-rsa publickeyDJFUWwuldk you@whatever"
homedir="/home/${user}"
pass=$(randalphnum 20)
cpass=$(perl -e 'printf("%s\n", crypt($ARGV[0], "password"))' "${pass}")
sshport=$(randnumb 4)
sshipv4=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')

#suicide="1"

if [ ${user} == "user" ]
then
printf "%b" "You forgot to edit the variables!"
fi

printf "%b" "\ntmpfs /dev/shm tmpfs defaults,ro 0 0 \n" >> /etc/fstab

printf "%b" "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1\nnet.ipv6.conf.eth0.disable_ipv6 = 1" >> /etc/sysctl.conf

touch /tmp/ipv4
printf "%b" "/sbin/iptables -A INPUT -i lo -j ACCEPT\n/sbin/iptables -A INPUT ! -i lo -s 127.0.0.0/8 -j REJECT\n/sbin/iptables -A INPUT -p icmp -m state --state NEW --icmp-type 8 -j ACCEPT\n/sbin/iptables -A INPUT -p tcp --dport ${sshport} -m state --state NEW -j ACCEPT\n/sbin/iptables -A INPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT\n/sbin/iptables -A INPUT -p tcp --dport 443 -m state --state NEW -j ACCEPT\n/sbin/iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT\n/sbin/iptables -A INPUT -m limit --limit 5/min -j LOG --log-level 7\n/sbin/iptables -A INPUT -j REJECT\n/sbin/iptables -A FORWARD -m limit --limit 5/min -j LOG --log-level 7\n/sbin/iptables -A FORWARD -j REJECT" >> /tmp/ipv4
chmod +x /tmp/ipv4
/tmp/ipv4
iptables-save > /etc/iptables/rules.v4
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

locale-gen en_US en_US.UTF-8


/usr/sbin/update-rc.d postfix disable
apt-get -y purge postfix
/usr/sbin/update-rc.d ntp disable
apt-get -y purge ntp
no="--no-install-recommends"
apt-get -y install dialog $no
apt-get -y install sudo $no
apt-get -y install ipset $no
apt-get -y install fail2ban $no
apt-get -y install nano $no 
apt-get -y install wget $no
apt-get -y install htop $no
apt-get -y install dnsutils $no
apt-get -y install whois $no
apt-get -y install acpid $no
apt-get -y install unzip $no
apt-get -y install tcpdump $no
apt-get -y install ca-certificates $no
#apt-get -y install --no-install-recommends checksecurity
#apt-get -y install --no-install-recommends chkrootkit
# specialty purpose
apt-get -y install sshfs $no


mkdir /etc/ssh/authorized_keys
touch /etc/ssh/authorized_keys/${user}
echo ${pubkey} > /etc/ssh/authorized_keys/${user}
chmod 0700 /etc/ssh/authorized_keys
chmod 0400 /etc/ssh/authorized_keys/${user}


groupadd admin
useradd -d "${homdir}" -g admin -m -p "${cpass}" -s /bin/bash random
chmod -R 0700 "${homedir}"
chown -R ${user}:admin "${homedir}"

cat >>/etc/sudoers <<EOL
${user}  ALL=(ALL) ALL
EOL

mv /etc/ssh/sshd_Config /tmp/bkup
touch /etc/ssh/sshd_config
printf "%b" "\nPort $sshport\n\nListenAddress 0.0.0.0\n\nKexAlgorithms curve25519-sha256@libssh.org\n\nCiphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr\n\nMACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-ripemd160-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,hmac-ripemd160,umac-128@openssh.com\n\nProtocol 2\n\nHostKey /etc/ssh/ssh_host_ed25519_key\n\nHostKey /etc/ssh/ssh_host_rsa_key\n\n\n# Optional restriction:\n\n# AllowUsers \nAllowUsers ${user} \n\n# AllowGroups \nAllowGroups admin\n\n#Privilege Separation is turned on for security\nUsePrivilegeSeparation yes\n\n# Lifetime and size of ephemeral version 1 server key\nKeyRegenerationInterval 1800\nServerKeyBits 2048\n\n# Logging\nSyslogFacility AUTH\nLogLevel INFO\n\n# Authentication:\n\nPubkeyAuthentication yes\nAuthorizedKeysFile	/etc/ssh/authorized_keys/%u\n\nPasswordAuthentication no\nLoginGraceTime 120\nPermitRootLogin no\nStrictModes yes\nIgnoreRhosts yes\nRhostsRSAAuthentication no\nHostbasedAuthentication no\nIgnoreUserKnownHosts yes\nPermitEmptyPasswords no\nChallengeResponseAuthentication no\nPasswordAuthentication no\nX11Forwarding no\nX11DisplayOffset 10\nPrintMotd no\nPrintLastLog yes\nTCPKeepAlive yes\nUseLogin no\nUsePAM no\n\nAcceptEnv LANG LC_*\n\n#MaxStartups 10:30:60\n#Banner /etc/issue.net\n\nSubsystem sftp /usr/lib/openssh/sftp-server\n" >> /etc/ssh/sshd_config

mv /etc/ssh/ssh_host_*key* /tmp/bkup
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key < /dev/null
ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key < /dev/null

service sshd restart

chmod -R 750 /sbin
chmod -R 750 /bin
chmod -R 750 /usr/sbin
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
mount –-bind /log/$HOSTNAME /var/log
mount –make-unbindable /log/$HOSTNAME
mount –make-shared /log/$HOSTNAME

printf "%b" "\n\n--------------------- COMPLETED -------------------------\n"
printf "%b" "User: ${user} \n"
printf "%b" "Password: $pass \n"
printf "%b" "Home Directory: $homedir \n"
printf "%b" "SSH Port: $sshport \n"
printf "%b" "SSH IP: $sshipv4 \n"
printf "%b" "--------------------- COMPLETED -------------------------\n\n"

exit 0
