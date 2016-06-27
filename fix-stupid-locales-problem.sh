#!/bin/bash

# One of these fucking commands will fix it!
# Tested and working on debian :)

# Purge/Install Stuff
sudo apt-get purge locales
sudo apt-get install locales
sudo apt-get install language-pack-en-base

# Write stuff
sudo sh -c "echo 'LC_ALL=en_US.UTF-8\nLANG=en_US.UTF-8' >> /etc/environment"
sudo sh -c "LC_ALL=en_EN.UTF-8" >> /etc/default/locale
sudo sh -c "export LANGUAGE=\"en_US.UTF-8\"
export LANG=\"en_US.UTF-8\"
export LC_ALL=\"en_US.UTF-8\"">>~/.bash_profile
echo "LANG=\"en_AU.UTF-8\"\nLANGUAGE=\"en_AU:en\"" >> ~/.profile
source ~/.bash_profile
source ~/.profile

# Configure stuff

sudo locale-gen "en_US.UTF-8"
sudo locale-gen en_EN.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

sudo dpkg-reconfigure locales

