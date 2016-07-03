#!/bin/bash

# Essential packages updater and installer
#
# Usage:
# chmod +x essentials.sh
# ./essentials <system type> (server, standard or virtual)
# OR
# ./essentials
#

function pgkserver()
{
    update
    apt-get -y install git sudo nano wget links iptraf htop nmap whois gnupg dnsutils iptables-persistent haveged rng-tools acpid apt-file bzip2 curl htop nmon ntp rsync tcpdump unzip ca-certificates;
    clean
}

function pkgstandard()
{
    update
    apt-get -y install git sudo nano wget links iptraf htop gnupg whois dnsutils haveged rng-tools acpid bzip2 curl htop rsync tcpdump unzip ca-certificates
    clean
}

function pkgvirtual()
{
    update
    apt-get -y install git sudo nano wget links iptraf htop dnsutils whois acpid unzip curl tcpdump rng-utils ca-certificates;     
    clean
}

function update ()
{
    apt-get update
    apt-get upgrade
    apt-get dist-upgrade
}

function clean()
{
    apt-get clean -y;
    apt-get autoclean -y;
    apt-get autoremove -y;
    exit 0
}


while true; do
    printf "%b" "1) Server\n2) Standard\n3) Virtual\n0) Exit\n"
    read -p "\n[?] Enter choice:" choice
    case $choice in
        1) pkgserver;;
        2) pkgstandard;;
        3) pkgvirtual;;
        0) exit;;
        * ) read -p "\n[?] Enter 0,1,2 or 3 :  " choice;;
    esac
done


