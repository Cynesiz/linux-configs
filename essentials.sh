#!/bin/bash

# Essential packages updater and installer
#
# Usage:
# chmod +x essentials.sh
# ./essentials <system type> (server, standard or virtual)
# OR
# ./essentials
#

function update ()
{
apt-get update
apt-get upgrade
apt-get dist-upgrade
}

while true; do
    read -p "\n[?] Choose: server / standard / virtual / quit :  " choice
    case $choice in
        [server]* ) update; apt-get -y install "git sudo nano wget links iptraf htop nmap gnupg dnsutils iptables-persistent haveged rng-tools acpid apt-file bzip2 curl htop nmon ntp rsync tcpdump unzip"; break;;
        [standard]* ) update; apt-get -y install "git sudo nano wget links iptraf htop gnupg dnsutils haveged rng-tools acpid bzip2 curl htop rsync tcpdump unzip"; break;;
        [virtual]* ) update; apt-get -y install "git sudo nano wget links iptraf htop dnsutils acpid unzip curl tcpdump rng-utils"; break;;
        [quit]* ) exit;;
        * ) read -p "\n[?] Choose: server / standard / virtual / quit :  " choice
    esac
done

apt-get clean -y;
apt-get autoclean -y;
apt-get autoremove -y;

exit 0
