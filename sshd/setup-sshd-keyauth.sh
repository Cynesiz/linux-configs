
NOT FINISHED!!!
Doesn't work!!!
exit 1


#!/bin/bash

# Semi-Authomated Secure SSHD and Enable Key Authenticaiton

# Set up SSH to accept SSH keys and listen on specified port
# Adds a user for you, disables root login, and adds you to sudo
# Generates an ssh key pair, adds yours to the authorized keys and 
# Dumps yours to stdout so you can copy it and add it to your keyring
# Writes keys to temporary files in your home directory during exectuion 
# When done, it overwritess them 3 times with random data and then rm's them

mkdir /root/backup
mv /etc/ssh/sshd_config /root/backup/sshd_config

myuser=username
sshport=22
# Change the above variables and then comment out the following line:
echo "You need to edit the script config first!";exit 1

cat >/etc/ssh/sshd_config <<EOL
# Package generated configuration file
# See the sshd_config(5) manpage for details

# What ports, IPs and protocols we listen for
Port ${sshport}
# Use these options to restrict which interfaces/protocols sshd will bind to
#ListenAddress ::
#ListenAddress 0.0.0.0
Protocol 2
# HostKeys for protocol version 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_dsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
#Privilege Separation is turned on for security
UsePrivilegeSeparation yes

# Lifetime and size of ephemeral version 1 server key
KeyRegenerationInterval 3600
ServerKeyBits 2048

# Logging
SyslogFacility AUTH
LogLevel INFO

# Authentication:
LoginGraceTime 120
PermitRootLogin no
StrictModes yes

RSAAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile	/etc/authorized_keys/%u

# Don't read the user's ~/.rhosts and ~/.shosts files
IgnoreRhosts yes
# For this to work you will also need host keys in /etc/ssh_known_hosts
RhostsRSAAuthentication no
# similar for protocol version 2
HostbasedAuthentication no
# Uncomment if you don't trust ~/.ssh/known_hosts for RhostsRSAAuthentication
#IgnoreUserKnownHosts yes

# To enable empty passwords, change to yes (NOT RECOMMENDED)
PermitEmptyPasswords no

# Change to yes to enable challenge-response passwords (beware issues with
# some PAM modules and threads)
ChallengeResponseAuthentication no

# Change to no to disable tunnelled clear text passwords
PasswordAuthentication no

# Kerberos options
#KerberosAuthentication no
#KerberosGetAFSToken no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes

# GSSAPI options
#GSSAPIAuthentication no
#GSSAPICleanupCredentials yes

X11Forwarding no
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
#UseLogin no

#MaxStartups 10:30:60
#Banner /etc/issue.net

# Allow client to pass locale environment variables
#AcceptEnv LANG LC_*

Subsystem sftp /usr/lib/openssh/sftp-server

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the ChallengeResponseAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via ChallengeResponseAuthentication may bypass
# the setting of "PermitRootLogin yes".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and ChallengeResponseAuthentication to 'no'.
UsePAM yes
EOL

mkdir /etc/ssh/authorized_keys

echo "Adding your user account.\n"
sleep 1
adduser --home /home/${myuser} --shell /bin/bash ${myuser}

update-alternatives --config editor

echo "Adding you to sudoers..."
echo "${myuser} ALL=(ALL:ALL) ALL" >> /etc/sudoers

runuser --user ${myuser} -- ssh-keygen -t rsa -b 4096 -f /home/${myuser}/tmp

pubbytes=$(stat -c%s "/home/${myuser}/tmp.pub")
keybytes=$(stat -c%s "/home/${myuser}/tmp")

skey=$(cat /home/${myuser}/tmp.pub)

echo ${skey} >> /etc/ssh/authorized_keys/${myuser}

printf "%s\n" "Key added to authorized keys:"

printf "%s\n\n" "Please add this private key to your client keyring."
cat /home/${myuser}/tmp

dd if=/dev/urandom of=/home/${myuser}/tmp.pub bs=${pubbytes} count=3 conv=notrunc
dd if=/dev/urandom of=/home/${myuser}/tmp bs=${keybytes} count=3 conv=notrunc

rm -rf /home/${myuser}/tmp.pub
rm -rf /home/${myuser}/tmp

echo "\nAll set.\nDouble check your config and then do: service ssh restart \n\n"
exit 0
