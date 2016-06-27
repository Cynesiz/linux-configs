#!/bin/bash



openssl genrsa -aes256 -out ca.key 4096
chmod 400 ca.key

openssl req -new -x509 -days 3650 -key ca.key -sha256 -extensions v3_ca -out ca.crt
chmod 400 ca.crt

openssl genrsa -out example.com.key 4096
chmod 400 example.com.key

openssl req -sha256 -new -key example.com.key -out example.com.csr
openssl x509 -sha256 -req -days 365 -in example.com.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out example.com.crt
