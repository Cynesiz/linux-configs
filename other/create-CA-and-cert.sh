#!/bin/bash

function makeca () 
{
openssl genrsa -aes256 -out ca.key ${keybits}
chmod 400 ca.key
}

function makecsr ()
{
openssl req -new -x509 -days ${daysvalid} -key ca.key -sha512 -extensions v3_ca -out ca.crt
chmod 400 ca.crt
}

function makecert ()
{
openssl genrsa -out "${domain}.key" $[keybits]
chmod 400 "${domain}.key"
openssl req -sha512 -new -key "${domain}.key" -out "${domain}.csr"
openssl x509 -sha512 -req -days ${daysvalid} -in "${domain}.csr" -CA ca.crt -CAkey ca.key -CAcreateserial -out "${domain}.crt"
}


if [ $# -eq 0 ]
then
    read -p "What domain do you want the cert for?  (example.com)" domain
    read -p "How many key bits? (2048, 4096, etc)" keybits
    read -p "How many days should cert be valid? (365)" daysvalid
    makeca
    makecsr
    makecert
    exit 0
else
dochoice $1
exit 0
fi

