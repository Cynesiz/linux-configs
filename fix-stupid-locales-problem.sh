#!/bin/bash

# One of these fucking commands will fix it!

sudo sh -c "echo 'LC_ALL=en_US.UTF-8\nLANG=en_US.UTF-8' >> /etc/environment"
echo "export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8">>~/.bash_profile
source ~/.bash_profile
sudo apt-get purge locales
sudo apt-get install locales
sudo apt-get install language-pack-en-base  
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
sudo locale-gen "en_US.UTF-8"
sudo dpkg-reconfigure locales

