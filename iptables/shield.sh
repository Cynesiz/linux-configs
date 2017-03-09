#!/bin/sh

# Author      : Adrien Pujol <adrien.pujol@crashdump.fr>                #
# Web site    : http://www.crashdump.fr/                                #
#   install rsyslog and create /etc/rsyslog.d/ip6tables.conf with:
#               :msg, contains, "[ip6tables]" -/var/log/ip6tables.log
#               & ~
#
#   logrotate that with the following config in /etc/logrotate.d/ip6tables.conf
#               /var/log/ip6tables.log {
#                   weekly
#                   missingok
#                   rotate 7
#                   compress
#                   delaycompress
#                   notifempty
#               }
#
#   Put this in /etc/init.d/ip6tables, then activate it:
#                            # /etc/init.d/ip6tables start
#                            # update-rc.d ip6tables defaults

#test -f /sbin/ip6tables || exit 0

#. /lib/lsb/init-functions

# Un peu de couleurs
#31=rouge, 32=vert, 33=jaune,34=bleu, 35=rose, 36=cyan, 37= blanc
color()
{
  #echo [$1`shift`m$*[m
  printf '\033[%sm%s\033[m\n' "$@"
}

#-----> VARIABLES A CONFIGURER <----------------------------------------#

IP6TABLES="/sbin/ip6tables"
IF_EXT=eth0
LOGFLAGS="LOG --log-tcp-options --log-tcp-sequence --log-ip-options --log-level warning --log-prefix"

log_success_msg() {
  color 35 "$@"
}

log_end_msg() {
  color 35 "$@"
}

echo4() {
        echo "- IP4 $@ : [`color 32 "OK"`]"
}
echo6() {
        echo "- IP6 $@ : [`color 32 "OK"`]"
}

WEB=80
MAIL=465
DNS=53
SSL=443
SSH=22
SSH2=23

WLIST=""

MYIP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')

TCPBurstNew=200
TCPBurstEst=50

IPTABLES="/sbin/iptables"

ExtraOne="false"
ExtraOneP=51066

ExtraTwo="false"
ExtraTwoP=28018

ExtraThree="false"
ExtraThreeP=0

#-----> START/STOP <----------------------------------------------------#

case "$1" in
    start)
        log_begin_msg "Starting ip6tables firewall rules..."
        ######################################################################

        #----- Initialisation --------------------------------------------------#

        echo ">Shutting down Fail2Ban"
        /etc/init.d/fail2ban stop

        echo ">Setting ipv6 firewall rules..."

        ## Vider les tables actuelles
        ${IP6TABLES} -t filter -F
        ${IP6TABLES} -t filter -X
        ${IP6TABLES} -t mangle -F
        ${IP6TABLES} -t mangle -X
        ${IP6TABLES} -F
        ${IP6TABLES} -X
        ${IP6TABLES} -Z
        echo6 "Flushed rules"

        #----- Default rules --------------------------------------------------#

        ## Police par defaut
        ${IP6TABLES} -P INPUT DROP
        ${IP6TABLES} -P OUTPUT DROP
        ${IP6TABLES} -P FORWARD DROP
        echo6 "Policy default, DROP "

        ## Loopback accepted
        ${IP6TABLES} -A FORWARD -i lo -o lo -j ACCEPT
        ${IP6TABLES} -A INPUT -i lo -j ACCEPT
        echo6 "Accept loopback on lo"

        #----- Chains creation  -------------------------------------------------#

        ## Creation des chaines
        ${IP6TABLES} -N SERVICES
        ${IP6TABLES} -N THISISPORN
        ${IP6TABLES} -N SECURITY
        echo "- Create custom chains : [`color 32 "OK"`]"

        #----- Security ---------------------------------------------------------#

        # Anyone who tried to portscan us is locked out for an entire day.
        ${IP6TABLES} -A SECURITY -m recent --name portscan --rcheck --seconds 86400 -j DROP                                            -m comment --comment "Portscan"
        # Once the day has passed, remove them from the portscan list
        ${IP6TABLES} -A SECURITY -m recent --name portscan --remove                                                                         -m comment --comment "Portscan"
        # These rules add scanners to the portscan list, and log the attempt.
        ${IP6TABLES} -A SECURITY -p tcp -m tcp --dport 139 -m recent --name portscan --set -j ${LOGFLAGS} "[ip6tables] [:portscan:]"         -m comment --comment "Portscan"
        ${IP6TABLES} -A SECURITY -p tcp -m tcp --dport 139 -m recent --name portscan --set -j DROP                                          -m comment --comment "Portscan"
        ${IP6TABLES} -A SECURITY -p tcp -m tcp --dport 5353 -m recent --name portscan --set -j ${LOGFLAGS} "[ip6tables] [:portscan:]"        -m comment --comment "Portscan"
        ${IP6TABLES} -A SECURITY -p tcp -m tcp --dport 5353 -m recent --name portscan --set -j DROP                                         -m comment --comment "Portscan"
        echo "- Portscan (Connect. on port 139 banned for a day) : [`color 32 "OK"`]"

        ## No NULL Packet
        ${IP6TABLES} -A SECURITY -p tcp --tcp-flags ALL NONE -m limit --limit 5/m --limit-burst 7 -j ${LOGFLAGS} "[ip6tables] [:nullpackets:]" -m comment --comment "Null packets"
        ${IP6TABLES} -A SECURITY -p tcp --tcp-flags ALL NONE -j DROP                                                                        -m comment --comment "Null packets"
        echo "- Drop and log NULL Packets : [`color 32 "OK"`]"

        ## No XMAS
        ${IP6TABLES} -A SECURITY -p tcp --tcp-flags SYN,FIN SYN,FIN -m limit --limit 5/m --limit-burst 7 -j ${LOGFLAGS} "[ip6tables] [:xmaspackets:]" -m comment --comment "Xmas packet"
        ${IP6TABLES} -A SECURITY -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP                                                                 -m comment --comment "Xmas packet"
        echo "- Drop and Log XMAS : [`color 32 "OK"`]"

        ## No FIN packet scans
        ${IP6TABLES} -A SECURITY -p tcp --tcp-flags FIN,ACK FIN -m limit --limit 5/m --limit-burst 7 -j ${LOGFLAGS} "[ip6tables] [:finpacketsscan:]" -m comment --comment "Fin packet"
        ${IP6TABLES} -A SECURITY -p tcp --tcp-flags FIN,ACK FIN -j DROP                                                                     -m comment --comment "Fin packet"
        ${IP6TABLES} -A SECURITY -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP                                                         -m comment --comment "Fin packet"
        echo "- Drop and log FIN packet scans : [`color 32 "OK"`]"

        ## No Broadcast / Multicast / Invalid and Bogus
        ${IP6TABLES} -A SECURITY -m pkttype --pkt-type broadcast -j ${LOGFLAGS} "[ip6tables] [:broadcast:]"                                  -m comment --comment "No broadcast"
        ${IP6TABLES} -A SECURITY -m pkttype --pkt-type broadcast -j DROP                                                                    -m comment --comment "No Broadcast"
        ${IP6TABLES} -A SECURITY -m pkttype --pkt-type multicast -j ${LOGFLAGS} "[ip6tables] [:multicast:]"                                  -m comment --comment "No multicast"
        ${IP6TABLES} -A SECURITY -m pkttype --pkt-type multicast -j DROP                                                                    -m comment --comment "No multicast"
        ${IP6TABLES} -A SECURITY -m state --state INVALID -j ${LOGFLAGS} "[ip6tables] [:invalid:]"                                           -m comment --comment "Invalid"
        ${IP6TABLES} -A SECURITY -m state --state INVALID -j DROP                                                                           -m comment --comment "Invalid"
        ${IP6TABLES} -A SECURITY -p tcp -m tcp --tcp-flags SYN,FIN SYN,FIN -j ${LOGFLAGS} "[ip6tables] [:bogus:]"                            -m comment --comment "Invalid"
        ${IP6TABLES} -A SECURITY -p tcp -m tcp --tcp-flags SYN,FIN SYN,FIN -j DROP                                                          -m comment --comment "Invalid"
        ${IP6TABLES} -A SECURITY -p tcp -m tcp --tcp-flags SYN,RST SYN,RST -j ${LOGFLAGS} "[ip6tables] [:bogus:]"                            -m comment --comment "Invalid"
        ${IP6TABLES} -A SECURITY -p tcp -m tcp --tcp-flags SYN,RST SYN,RST -j DROP                                                          -m comment --comment "Invalid"
        echo "- No Broadcast / Multicast / Invalid and Bogus : [`color 32 "OK"`]"

        ## REJECT les fausses connex pretendues s'initialiser et sans syn
        ${IP6TABLES} -A SECURITY -p tcp ! --syn -m state --state NEW,INVALID -j ${LOGFLAGS} "[ip6tables] [:falsenosyn:]"                     -m comment --comment "NoSyn"
        ${IP6TABLES} -A SECURITY -p tcp ! --syn -m state --state NEW,INVALID -j DROP                                                        -m comment --comment "NoSyn"
        echo "- Rejeter les fakes de connection, pas de syn : [`color 32 "OK"`]"

        ## icmp neighbor-*
        ${IP6TABLES} -A INPUT -i ${IF_EXT} -p ipv6-icmp --icmpv6-type neighbor-advertisement -j ACCEPT
        ${IP6TABLES} -A INPUT -i ${IF_EXT} -p ipv6-icmp --icmpv6-type neighbor-solicitation -j ACCEPT

        ## Ne pas casser les connexions etablies
        ${IP6TABLES} -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
        echo "- Ne pas casser les connexions etablies : [`color 32 "OK"`]"

        #----- Debut des regles  ------------------------------------------------#

        ${IP6TABLES} -A THISISPORN -s 2001:1041:444:3::/64 -j DROP       -m comment --comment "Scanned me"
        ${IP6TABLES} -A THISISPORN -s 2001:4a48:217:1::/64 -j DROP       -m comment --comment "Bruteforced me"

        # Autoriser SSH
#        ${IP6TABLES} -A SERVICES -p tcp --dport 22 -j ACCEPT                                               -m comment --comment "sshd"
#        echo "- Autoriser SSH (ipv6) : [`color 32 "OK"`]"

        # Autoriser les requetes HTTP
        ${IP6TABLES} -A SERVICES -p tcp --dport 80 -j ACCEPT                                               -m comment --comment "http"
        ${IP6TABLES} -A SERVICES -p tcp --dport 443 -j ACCEPT                                              -m comment --comment "https"
        echo "- Autoriser les requetes HTTP/S (ipv6) : [`color 32 "OK"`]"

        # Ecriture de la politique de log
        # Ici on affiche [IPTABLES DROP] dans /var/log/messages a chaque paquet rejette par iptables
        ${IP6TABLES} -N LOG_DROP
        ${IP6TABLES} -A LOG_DROP -j ${LOGFLAGS} '[ip6tables] [:finaldrop:]'
        ${IP6TABLES} -A LOG_DROP -j DROP

        # On met en place les logs en entree, sortie et routage selon la politique LOG_DROP ecrit avant
        ${IP6TABLES} -A FORWARD -j LOG_DROP
        ${IP6TABLES} -A INPUT -j LOG_DROP
        #
        ${IP6TABLES} -I INPUT -i ${IF_EXT} -j SERVICES
        ${IP6TABLES} -I INPUT -i ${IF_EXT} -j SECURITY
        ${IP6TABLES} -I INPUT  -j THISISPORN
        echo "- Mise en place des politiques prededement definies : [`color 32 "OK"`]"


echo "Starting IPv4 Ruleset..."
echo ""
sleep 0.5

${IPTABLES} -N PSAD_BLOCK_INPUT
${IPTABLES} -N PSAD_BLOCK_OUTPUT
${IPTABLES} -N PSAD_BLOCK_FORWARD
echo4 "Creating PSAD Chains"



if [ "$ExtraOne" = "yes" ]
then
   echo "Opening Extra Port One: $ExtraOneP"
else
    echo "Not Using Extra Port One.."
fi
sleep 0.3
if [ "$ExtraTwo" = "yes" ]
then
   echo "Opening Extra Port Two: $ExtraTwoP"
else
    echo "Not Using Extra Port Two.."
fi
sleep 0.3
if [ "$ExtraThree" = "yes" ]
then
   echo "Opening Extra Port Three: $ExtraThreeP"
else
    echo "Not Using Extra Port Three.."
fi

echo "Lets start by Flushing your old Rules."
sleep 0.3

${IPTABLES} -F
${IPTABLES} -t nat -F
${IPTABLES} -X

${IPTABLES} -t nat -P PREROUTING  ACCEPT
${IPTABLES} -t nat -P POSTROUTING ACCEPT
${IPTABLES} -t nat -P OUTPUT      ACCEPT

${IPTABLES} -t nat -A POSTROUTING -o eth0 -j MASQUERADE

${IPTABLES} -P INPUT   ACCEPT
${IPTABLES} -P FORWARD ACCEPT
${IPTABLES} -P OUTPUT  ACCEPT

echo4 "Done!"
sleep 0.3

echo4 "We need to create the Default rule and Accept LoopBack Input."
sleep 0.3

${IPTABLES} -A INPUT -i lo -p all -j ACCEPT

echo4 "Done!"
sleep 0.3

for whost in ${WLIST}
do
  printf 'Whitelisting Host: %s\n' "$whost"
  ${IPTABLES} -A INPUT -i eth0 -s $whost -j ACCEPT
  ${IPTABLES} -A OUTPUT -o eth0 -d $whost -j ACCEPT
done

echo4 "Create whitelist rules."

sleep 0.3


echo4 "Enabling the 3 Way Hand Shake and limiting TCP Requests."
echo4 "IF YOU ARE USING CLOUD FLARE AND EXPERIENCE ISSUES INCREASE TCPBurst"
sleep 1

${IPTABLES} -A INPUT -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
${IPTABLES} -A INPUT -i eth0 -p tcp --dport $WEB -m state --state NEW -m limit --limit 50/minute --limit-burst $TCPBurstNew -j ACCEPT
${IPTABLES} -A INPUT -i eth0 -p tcp --dport $SSL -m state --state NEW -m limit --limit 50/minute --limit-burst $TCPBurstNew -j ACCEPT
${IPTABLES} -A INPUT -i eth0 -m state --state RELATED,ESTABLISHED -m limit --limit 50/second --limit-burst $TCPBurstEst -j ACCEPT

echo4 "Done!"
sleep 0.3
echo4 "Adding Protection from LAND Attacks, If these IPs look required, please stop the script and alter it."

echo4 "10.0.0.0/8 DROP"
sleep 0.3
${IPTABLES} -A INPUT -i eth0 -s 10.0.0.0/8 -j DROP
echo4 "169.254.0.0/16 DROP"
sleep 0.3
${IPTABLES} -A INPUT -i eth0 -s 169.254.0.0/16 -j DROP
echo4 "172.16.0.0/12 DROP"
sleep 0.3
${IPTABLES} -A INPUT -i eth0 -s 172.16.0.0/12 -j DROP
echo4 "127.0.0.0/8 DROP"
sleep 0.3
${IPTABLES} -A INPUT -i eth0 -s 127.0.0.0/8 -j DROP
echo4 "192.168.0.0/24 DROP"
sleep 0.3
${IPTABLES} -A INPUT -i eth0 -s 192.168.0.0/24 -j DROP
echo4 "224.0.0.0/4 SOURCE DROP"
sleep 0.3
${IPTABLES} -A INPUT -i eth0 -s 224.0.0.0/4 -j DROP
echo4 "224.0.0.0/4 DEST DROP"
sleep 0.3
${IPTABLES} -A INPUT -i eth0 -d 224.0.0.0/4 -j DROP
echo4 "224.0.0.0/5 SOURCE DROP"
sleep 0.3
${IPTABLES} -A INPUT -i eth0 -s 240.0.0.0/5 -j DROP
echo4 "224.0.0.0/5 DEST DROP"
sleep 0.3
${IPTABLES} -A INPUT -i eth0 -d 240.0.0.0/5 -j DROP
echo4 "0.0.0.0/8 SOURCE DROP"
sleep 0.3
${IPTABLES} -A INPUT -i eth0 -s 0.0.0.0/8 -j DROP
echo4 "0.0.0.0/8 DEST DROP"
sleep 0.3
${IPTABLES} -A INPUT -i eth0 -d 0.0.0.0/8 -j DROP
echo4 "239.255.255.0/24 DROP SUBNETS"
sleep 0.3
${IPTABLES} -A INPUT -i eth0 -d 239.255.255.0/24 -j DROP
echo4 "255.255.255.255 DROP SUBNETS"
sleep 0.3
${IPTABLES} -A INPUT -i eth0 -d 255.255.255.255 -j DROP

echo4 "Done!"
sleep 0.3

echo4 "Protect against SYN floods by rate limiting the number of new connections from any host to 60 per second.  This does *not* do rate"
${IPTABLES} -A INPUT -i eth0 -m state --state NEW -p tcp -m tcp --syn -m recent --name synflood --update --seconds 1 --hitcount 60 -j DROP

echo4 "Reply to unknown 'NEW' SYN/ACK packets with a RESET, so we can't be used as a middle-man for Sequence Number Prediction based spoof attacks"
${IPTABLES} -A INPUT -i eth0 -m state --state NEW -p tcp -m tcp --tcp-flags SYN,ACK SYN,ACK -j REJECT --reject-with tcp-reset

echo4 "Drop bogus TCP packets"
${IPTABLES} -A INPUT -i eth0 -p tcp -m tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
${IPTABLES} -A INPUT -i eth0 -p tcp -m tcp --tcp-flags SYN,RST SYN,RST -j DROP

echo4 "Log and drop NEW packets which don't have the SYN bit set"
${IPTABLES} -A INPUT -i eth0 -m state --state NEW -p tcp -m tcp ! --syn -j LOG --log-level 4 --log-prefix "New !SYN:"
${IPTABLES} -A INPUT -i eth0 -m state --state NEW -p tcp -m tcp ! --syn -j DROP

echo4 "If any packets reach this point that have the ACK bit sent (but not SYN), respond with a TCP reset"
${IPTABLES} -A INPUT -i eth0 -p tcp -m tcp --tcp-flags ACK ACK -j REJECT --reject-with tcp-reset

echo4 "Lets stop ICMP SMURF Attacks at the Door."
${IPTABLES} -A INPUT -i eth0 -p icmp -m icmp --icmp-type address-mask-request -j DROP
${IPTABLES} -A INPUT -i eth0 -p icmp -m icmp --icmp-type timestamp-request -j DROP
${IPTABLES} -A INPUT -i eth0 -p icmp -m icmp --icmp-type 0 -m limit --limit 1/second -j ACCEPT

echo4 "Reject packets spoofed to appear as if from us"
${IPTABLES} -A INPUT -i eth0 -s $MYIP   -j DROP

sleep 0.3
echo4 "Done!"

echo4 "Next were going to drop all INVALID packets."

${IPTABLES} -A INPUT -i eth0 -m state --state INVALID -j DROP
${IPTABLES} -A FORWARD -m state --state INVALID -j DROP
${IPTABLES} -A OUTPUT -m state --state INVALID -j DROP

sleep 0.3
echo4 "Done!"
echo4 "Next we drop VALID but INCOMPLETE packets. (Idk why this is even possible)"

${IPTABLES} -A INPUT -i eth0 -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
${IPTABLES} -A INPUT -i eth0 -p tcp -m tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
${IPTABLES} -A INPUT -i eth0 -p tcp -m tcp --tcp-flags SYN,RST SYN,RST -j DROP
${IPTABLES} -A INPUT -i eth0 -p tcp -m tcp --tcp-flags FIN,RST FIN,RST -j DROP
${IPTABLES} -A INPUT -i eth0 -p tcp -m tcp --tcp-flags FIN,ACK FIN -j DROP
${IPTABLES} -A INPUT -i eth0 -p tcp -m tcp --tcp-flags ACK,URG URG -j DROP

sleep 0.3
echo4 "Done!"
echo4 "Now we're going to enable RST Flood Protection"

${IPTABLES} -A INPUT -i eth0 -p tcp -m tcp --tcp-flags RST RST -m limit --limit 2/second --limit-burst 2 -j ACCEPT

sleep 0.3

echo4 "Allow most ICMP packets to be received (so people can check our"
echo4 "presence), but restrict the flow to avoid ping flood attacks"
${IPTABLES} -A INPUT -i eth0 -p icmp -m icmp --icmp-type address-mask-request -j DROP
${IPTABLES} -A INPUT -i eth0 -p icmp -m icmp --icmp-type timestamp-request -j DROP
${IPTABLES} -A INPUT -i eth0 -p icmp -m icmp --icmp-type redirect -j DROP
${IPTABLES} -A INPUT -i eth0 -p icmp -m icmp -m limit --limit 1/second -j ACCEPT
${IPTABLES} -A INPUT -i eth0 -p icmp -m icmp --icmp-type 8 -j REJECT

sleep 0.3
echo4 "Done!"
echo4 "Allowing the following ports through from the outside"

echo4 "Special rules for port knocks"
${IPTABLES} -A INPUT -i eth0 -p tcp -m tcp --dport 61681 -j DROP
${IPTABLES} -A INPUT -i eth0 -p tcp -m tcp --dport 18191 -j DROP
${IPTABLES} -A INPUT -i eth0 -p tcp -m tcp --dport 20231 -j DROP
${IPTABLES} -A INPUT -i eth0 -p udp -m udp --dport 47041 -j DROP
${IPTABLES} -A INPUT -i eth0 -p udp -m udp --dport 47881 -j DROP
${IPTABLES} -A INPUT -i eth0 -p udp -m udp --dport 33049 -j DROP

echo4 "DROP SSH Port $SSH (only allow with knockd)"
${IPTABLES} -A INPUT -i eth0 -p tcp -m tcp --dport $SSH -j DROP
${IPTABLES} -A OUTPUT -p tcp -m tcp --sport $SSH -j ACCEPT


echo4 "Allow 80/443 Portforwarding to LXC"

${IPTABLES} -t nat -A PREROUTING  -p tcp -m tcp -d $MYIP --dport 80 -j DNAT --to-destination 10.0.3.100:80
${IPTABLES} -A FORWARD -m state -p tcp -d 10.0.3.100 --dport 80 --state NEW,ESTABLISHED,RELATED -j ACCEPT
${IPTABLES} -t nat -A POSTROUTING -p tcp -m tcp -s 10.0.3.100 --sport 80 -j SNAT --to-source $MYIP

${IPTABLES} -t nat -A PREROUTING  -p tcp -m tcp -d $MYIP --dport 443 -j DNAT --to-destination 10.0.3.100:443
${IPTABLES} -A FORWARD -m state -p tcp -d 10.0.3.100 --dport 443 --state NEW,ESTABLISHED,RELATED -j ACCEPT
${IPTABLES} -t nat -A POSTROUTING -p tcp -m tcp -s 10.0.3.100 --sport 443 -j SNAT --to-source $MYIP

echo4 "Allow IP Masqerade from LXC"

${IPTABLES} -t nat -A POSTROUTING -o eth0 -j MASQUERADE
${IPTABLES} -A FORWARD -i eth0 -o lxcbr0 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT

${IPTABLES} -A INPUT -i lxcbr0 -s 10.0.3.0/24 -d 10.0.3.0/24 -j ACCEPT
${IPTABLES} -A OUTPUT -o lxcbr0 -s 10.0.3.0/24 -d 10.0.3.0/24 -j ACCEPT

#${IPTABLES} -A INPUT -i lxcbr0 -s 10.0.3.0/24 -d 10.0.3.1/32 -p tcp --dport 22 -j DROP
${IPTABLES} -A INPUT -i lxcbr0 -s 10.0.3.0/24 -d 10.0.3.1/32 -p tcp --dport 51066 -j DROP
${IPTABLES} -A INPUT -i lxcbr0 -s 10.0.3.0/24 -d 10.0.3.1/32 -p tcp --dport 80 -j DROP
${IPTABLES} -A INPUT -i lxcbr0 -s 10.0.3.0/24 -d 10.0.3.1/32 -p tcp --dport 443 -j DROP


${IPTABLES} -A OUTPUT -o eth0 -p tcp --dport 80 -j ACCEPT
${IPTABLES} -A OUTPUT -o eth0 -p tcp --dport 443 -j ACCEPT
${IPTABLES} -A OUTPUT -o eth0 -p tcp --dport 6667 -j ACCEPT
${IPTABLES} -A OUTPUT -o eth0 -p tcp --dport 7000 -j ACCEPT


echo4 "Block potential bad traffic INPUT from LXC"

${IPTABLES} -t nat -A POSTROUTING -o eth0 -j MASQUERADE
${IPTABLES} -A FORWARD -i eth0 -o honey0 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT

#${IPTABLES} -A INPUT -i honey0 -s 172.16.0.0/24 -d 172.16.0.1/32 -p tcp --dport 22 -j DROP
${IPTABLES} -A INPUT -i honey0 -s 172.16.0.0/24 -d 172.16.0.1/32 -p tcp --dport 51066 -j DROP
${IPTABLES} -A INPUT -i honey0 -s 172.16.0.0/24 -d 172.16.0.1/32 -p tcp --dport 80 -j DROP
${IPTABLES} -A INPUT -i honey0 -s 172.16.0.0/24 -d 172.16.0.1/32 -p tcp --dport 443 -j DROP

${IPTABLES} -A INPUT -i honey0 -s 172.16.0.0/24 -d 172.16.0.0/24 -j ACCEPT
${IPTABLES} -A OUTPUT -o honey0 -s 172.16.0.0/24 -d 172.16.0.0/24 -j ACCEPT





#${IPTABLES} -A FORWARD -j REJECT
${IPTABLES} -A INPUT -i lxcbr0 -p icmp -s 10.0.3.0/24 -d 10.0.3.1 -j ACCEPT


sleep 0.3
echo4 "Done Opening Ports For Web Access!"

#echo4 "Lastly we block ALL OTHER INPUT TRAFFIC."
#${IPTABLES} -A INPUT -i eth0 -j DROP
#
#sleep 0.3
#echo4 "Done!"

################# Below are OUTPUT iptables rules #############################################
echo4 "NOW LETS SET UP OUTPUTS"

echo4 "Default Rule for OUTPUT and our LoopBack Again. We wont be limiting outgoing traffic."
${IPTABLES} -A OUTPUT -o lo -j ACCEPT
${IPTABLES} -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

sleep 0.3
echo4 "Done!"

echo4 "Allowing the following ports Access OUT from the INSIDE"

echo4 "OUT SMTP Port 465"
${IPTABLES} -A OUTPUT -p tcp -m tcp --dport 465 -j ACCEPT

sleep 1
echo4 "Done!"

echo4 "OUT DNS Port $DNS"
${IPTABLES} -A OUTPUT -p udp -m udp --dport $DNS -j ACCEPT

sleep 1
echo4 "Done!"

echo4 "OUT Web Port $WEB"
${IPTABLES} -A OUTPUT -p tcp -m tcp --dport $WEB -j ACCEPT
${IPTABLES} -A OUTPUT -p tcp -m tcp --sport $WEB -j ACCEPT

sleep 1
echo4 "Done!"

echo4 "OUT HTTPS Port $SSL"
${IPTABLES} -A OUTPUT -p tcp -m tcp --dport $SSL -j ACCEPT
${IPTABLES} -A OUTPUT -p tcp -m tcp --sport $SSL -j ACCEPT

sleep 1
echo4 "Done!"

echo4 "OUT SSH Port 22"
${IPTABLES} -A OUTPUT -p tcp -m tcp --dport 22 -j ACCEPT

sleep 1

echo4 "OUT GPG Keyserver port 11371"
${IPTABLES} -A OUTPUT -p tcp --dport 11371 -j ACCEPT

sleep 1

sleep 1
echo4 "Done!"

echo4 "Allowing Outgoing PING Type ICMP Requests, So we don't break things."

${IPTABLES} -A OUTPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT

sleep 1
echo4 "Done!"

echo4 "Rejecting all other Output traffic"

${IPTABLES} -A OUTPUT -j REJECT

sleep 0.3
echo4 "Done!"


echo4 "Setting default policy: LOG_DROP"

        ${IPTABLES} -N LOG_DROP
        ${IPTABLES} -A LOG_DROP -j ${LOGFLAGS} '[iptables] [:finaldrop:]'
        ${IPTABLES} -A LOG_DROP -j DROP

        ${IPTABLES} -A FORWARD -i eth0 -j LOG_DROP
        ${IPTABLES} -A INPUT -i eth0 -j LOG_DROP


#echo4 "Rejecting all Forwarding traffic"

#${IPTABLES} -A FORWARD -j REJECT

      ##
        echo ">Starting Fail2Ban"
        sleep 5
        /etc/init.d/fail2ban start
        sleep 1

        echo "- Fail2Ban active modules: "
        echo `ip6tables -L -nv --line-numbers | grep -e "Chain fail2ban-"`

        echo "`color 32 ">Firewall rules set successfully. !"`"

        ######################################################################
        log_end_msg $?
        ;;

    stop)
        log_begin_msg "Flushing rules..."
        ${IP6TABLES} -t filter -F
        ${IP6TABLES} -t filter -X
        ${IP6TABLES} -t mangle -F
        ${IP6TABLES} -t mangle -X
        ${IP6TABLES} -F
        ${IP6TABLES} -X
        ${IP6TABLES} -Z
        ${IP6TABLES} -P INPUT ACCEPT
        ${IP6TABLES} -A INPUT -j ACCEPT
        ${IP6TABLES} -P OUTPUT ACCEPT
        ${IP6TABLES} -A OUTPUT -j ACCEPT
        ${IP6TABLES} -P FORWARD ACCEPT
        ${IP6TABLES} -A FORWARD -j ACCEPT

${IPTABLES} -F
${IPTABLES} -t nat -F
${IPTABLES} -X

${IPTABLES} -t nat -P PREROUTING  ACCEPT
${IPTABLES} -t nat -P POSTROUTING ACCEPT
${IPTABLES} -t nat -P OUTPUT      ACCEPT

${IPTABLES} -t nat -A POSTROUTING -o eth0 -j MASQUERADE

${IPTABLES} -P INPUT   ACCEPT
${IPTABLES} -P FORWARD ACCEPT
${IPTABLES} -P OUTPUT  ACCEPT

        log_end_msg $?

${IPTABLES} -L -nv
${IPTABLES} -L -nv -t nat
        ;;


        restart)
        $0 stop
        $0 start
${IPTABLES} -L -nv
${IPTABLES} -L -nv -t nat
        ;;



    status)
        ${IP6TABLES} -nvL
        ;;


    *)
        log_success_msg "Usage: /etc/init.d/ip6tables {start|stop|restart|status}"
        exit 1
        ;;
esac

exit 0

