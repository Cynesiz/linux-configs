#!/bin/bash +x

  # first author: marcos de vera
  # second: joan marc riera
  # Modified by Reimannian

  ip=/sbin/iptables
  vpn=""
  home=""
  admins="$vpn $home "
  sshers="$vpn $home "
  mysqlrs=""
  tcpservices="80 443"
  udpservices=""

  # Firewall script for servername

  echo -n ">> Applying iptables rules... "

  ## flushing...
  $ip -F
  $ip -X
  $ip -Z
  $ip -t nat -F

  # default: DROP!
  $ip -P INPUT DROP
  $ip -P OUTPUT DROP
  $ip -P FORWARD DROP

  # filtering...

  # localhost: free pass!
  $ip -A INPUT -i lo -j ACCEPT
  $ip -A OUTPUT -o lo -j ACCEPT

  # administration ips: free pass!
  for admin in $admins ; do
      $ip -A INPUT -s $admin -j ACCEPT
      $ip -A OUTPUT -d $admin -j ACCEPT
  done

  # allow ssh access to sshers
  for ssher in $sshers ; do
      $ip -A INPUT -s $ssher -p tcp -m tcp --dport 22 -j ACCEPT
      $ip -A OUTPUT -d $ssher -p tcp -m tcp --sport 22 -j ACCEPT
  done

  # allow access to mysql port to iReport on sugar

  for mysql in $mysqlrs ; do
      $ip -A INPUT -s $mysql -p tcp -m tcp --dport 3306 -j ACCEPT
      $ip -A OUTPUT -d $mysql -p tcp -m tcp --sport 3306 -j ACCEPT
      $ip -A INPUT -s $mysql -p udp -m udp --dport 3306 -j ACCEPT
      $ip -A OUTPUT -d $mysql -p udp -m udp --sport 3306 -j ACCEPT
  done


  # allowed services
  for service in $tcpservices ; do
      $ip -A INPUT -p tcp -m tcp --dport $service -j ACCEPT
      $ip -A OUTPUT -p tcp -m tcp --sport $service -m state --state RELATED,ESTABLISHED -j ACCEPT
  done
  for service in $udpservices ; do
      $ip -A INPUT -p udp -m udp --dport $service -j ACCEPT
      $ip -A OUTPUT -p udp -m udp --sport $service -m state --state RELATED,ESTABLISHED -j ACCEPT
  done

  #$ip -A INPUT -j LOG --log-level 4
  
  # allow the machine to browse the internet
  $ip -A INPUT -p tcp -m tcp --sport 80 -m state --state RELATED,ESTABLISHED -j ACCEPT
  $ip -A OUTPUT -p tcp -m tcp --dport 80 -j ACCEPT
  $ip -A INPUT -p tcp -m tcp --sport 443 -m state --state RELATED,ESTABLISHED -j ACCEPT
  $ip -A OUTPUT -p tcp -m tcp --dport 443 -j ACCEPT

  $ip -A INPUT -p tcp -m tcp --sport 8080 -m state --state RELATED,ESTABLISHED -j ACCEPT
  $ip -A OUTPUT -p tcp -m tcp --dport 8080 -j ACCEPT


  # don't forget the dns...
  $ip -A INPUT -p udp -m udp --sport 53 -m state --state RELATED,ESTABLISHED -j ACCEPT
  $ip -A OUTPUT -p udp -m udp --dport 53 -j ACCEPT
  $ip -A INPUT -p tcp -m tcp --sport 53 -m state --state RELATED,ESTABLISHED -j ACCEPT
  $ip -A OUTPUT -p tcp -m tcp --dport 53 -j ACCEPT

  # ... neither the ntp... (hora.rediris.es)
  #$ip -A INPUT -s 130.206.3.166 -p udp -m udp --dport 123 -j ACCEPT
  #$ip -A OUTPUT -d 130.206.3.166 -p udp -m udp --sport 123 -j ACCEPT

  $ip -A INPUT -p udp -m udp --dport 123 -m state --state RELATED,ESTABLISHED -j ACCEPT
  $ip -A OUTPUT -p udp -m udp --sport 123 -j ACCEPT

  # temporary backup if we change from DROP to ACCEPT policies
  #$ip -A INPUT -p tcp -m tcp --dport 1:1024 -j DROP
  #$ip -A INPUT -p udp -m udp --dport 1:1024 -j DROP

  $ip -L -n
  
  # end :)
