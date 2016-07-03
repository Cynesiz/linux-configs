#!/bin/bash

sudo rm -rf /var/lib/dpkg/updates/*
sudo rm -rf /var/lib/apt/lists/*
sudo rm /var/cache/apt/*.bin
sudo apt-get clean
sudo apt-get autoremove
sudo apt-get update
sudo dpkg --configure -a
sudo apt-get install -f
