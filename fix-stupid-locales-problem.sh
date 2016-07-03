#!/bin/bash

# This shit is so annoying

# Purge/Install Stuff
sudo apt-get purge locales
sudo apt-get install locales
sudo apt-get install language-pack-en-base
# Export stuff
export LANGUAGE="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
# Configure stuff
echo "AcceptEnv LANG LC_*" >> /etc/ssh/sshd_config
service sshd restart
# Configure the rest of the stuff
sudo locale-gen "en_US.UTF-8"
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 
sudo dpkg-reconfigure locales

