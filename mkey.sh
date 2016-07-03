#!/bin/bash

# Shortcut functions/alias for ssh-keygen

# Generate Host Keys

function hkeygen ()
{
if [[ $EUID -ne 0 ]]; then
  printf "%s" "You must be a root user to generate host keys!" 2>&1
  exit 1
else
  printf "%b" "\n\e[30;48;5;82m Generating New Host ID Keys \e[0m \n" 
  printf "%b" "\n\e[40;38;5;82m Output Directory: /etc/ssh \e[0m \n"
  rm -rf /etc/ssh/ssh_host*
  sleep 2
  ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key < /dev/null
  ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key < /dev/null
  printf "%b" "\n\e[40;38;5;82m Executing: chmod 0600 /etc/ssh/ssh_host* \e[0m \n"
  sleep 1
  chmod 0600 /etc/ssh/ssh_host*
  printf "%s" "Done!"
fi
}

# Generate Client Keys

function ckeygen ()
{
  printf "%b" "\n\e[30;48;5;82m Generating Client SSH Keys \e[0m \n" 
  printf "%b" "\n\e[40;38;5;82m Output Directory: $(echo ~/.ssh) \e[0m \n"
  ssh-keygen -t ed25519 -f $(echo ~/.ssh/$1_ed25519)
  ssh-keygen -t rsa -b 4096 -f $(echo ~/.ssh/$1_rsa)
  printf "%b" "\n\e[40;38;5;82m Executing: chmod -R 0600 $(echo ~/.ssh) \e[0m \n"
  chmod -R 0600 $(echo ~/.ssh)
  printf "%b" "\n\e[40;38;5;82m Public keys are as follows... \e[0m \n"
  printf "%b" "\n\e[40;38;5;82m ED25519 \e[0m \n"
  cat $(echo ~/.ssh/$1_ed25519.pub)
  printf "%b" "\n\e[40;38;5;82m RSA4096 \e[0m \n"
  cat $(echo ~/.ssh/$1_rsa.pub)
  printf "b" "Process successful, exititing 0\n"
  exit 0
}

# Handle CLI arguments

if [ $# -eq 0 ]; 
then
    printf "%s" "Usage: $0 <host/client> <name (client only, optional)> "
    exit 1
else
  if [ $1 == 'host' ]; 
  then
    hkeygen
  else
    if [ $2 -eq 0 ]; 
    then
      ckeygen id
    else
      ckeygen $2
    fi
  fi
fi

