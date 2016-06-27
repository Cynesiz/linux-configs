#!/bin/bash

apt-get update
apt-get upgrade
apt-get dist-upgrade

PACKAGES="
build-essential sudo nano iptraf htop nmap gnupg dnsutils 
iptables-persistent fail2ban haveged rng-tools acpid apt-file bind9-host bzip2
curl emacs24-nox htop nmon ntp rsync slurm tcpdump unzip vim-nox
"
apt-get -y install $PACKAGES

