#!/bin/bash

sh -c "echo 'LC_ALL=en_US.UTF-8\nLANG=en_US.UTF-8' >> /etc/environment" 

apt-get update
apt-get upgrade
apt-get dist-upgrade

apt-get install build-essential sudo nano iptraf htop nmap gnupg dnsutils iptables-persistent fail2ban haveged rng-tools
