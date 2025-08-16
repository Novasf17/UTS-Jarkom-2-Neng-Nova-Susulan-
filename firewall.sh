
#!/bin/bash
# Reset rules
iptables -F

# Accept loopback & established
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow internal subnet
iptables -A INPUT -s 192.168.10.0/24 -j ACCEPT

# Open important ports
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Drop ICMP from outside subnet
iptables -A INPUT -p icmp -s ! 192.168.10.0/24 -j DROP

# Drop everything else
iptables -A INPUT -j DROP
