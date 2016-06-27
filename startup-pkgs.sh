#!/bin/bash

PKGSERVER="git sudo nano iptraf htop nmap gnupg dnsutils iptables-persistent haveged rng-tools acpid apt-file bzip2 curl htop nmon ntp rsync slurm tcpdump unzip"
PKGSTANDARD="git sudo nano iptraf htop nmap gnupg dnsutils iptables-persistent haveged rng-tools acpid apt-file bzip2 curl htop nmon ntp rsync slurm tcpdump unzip"
PKGVIRTUAL="git sudo nano iptraf htop dnsutils acpid bzip2 unzip"

function setup ()
{
if [[ $1 == "server" ]] 
then
apt-get -y install ${PKGSERVER}
elif [[ $1 == "standard" ]] 
then
apt-get -y install ${PKGSTANDARD}
elif [[ $1 == "virtual" ]] 
then
apt-get -y install ${PKGVIRTUAL}
else
echo "No choice given."
fi
}

function update ()
{
apt-get update
apt-get upgrade
apt-get dist-upgrade
}

function dochoice ()
{
    case $1 in
        [server]* ) update; setup server; break;;
        [standard]* ) update; setup standard; break;;
        [virtual]* ) update; setup virtual; break;;
        [quit]* ) exit;;
        * ) echo "Please enter server, standard, virtual or quit.";;
    esac
}

if [ $# -eq 0 ]
then
while true; do
    read -p "Enter: Server, Standard or Virtual :  " choice
    dochoice $choice
done
else
dochoice $1
fi

