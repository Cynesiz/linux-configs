#!/bin/bash

apt-get update
apt-get upgrade
apt-get dist-upgrade

PACKAGES="
git sudo nano iptraf htop nmap gnupg dnsutils 
iptables-persistent haveged rng-tools acpid apt-file bzip2
curl htop nmon ntp rsync slurm tcpdump unzip
"
apt-get -y install $PACKAGES

