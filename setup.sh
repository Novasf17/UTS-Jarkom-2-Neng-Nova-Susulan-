
#!/bin/bash
# Quick setup for DHCP, DNS (Bind9), and iptables on Ubuntu

set -e

echo "[1/6] Updating packages..."
apt update && apt install -y isc-dhcp-server bind9 iptables-persistent net-tools

echo "[2/6] Placing DHCP configs..."
install -m 0644 dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf || cp dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf
# Detect first non-loopback interface if INTERFACESv4 not set
IFACE="$(ip -o -4 route show to default | awk '{print $5}' | head -n1)"
echo "INTERFACESv4=\"${IFACE}\"" > /etc/default/isc-dhcp-server

echo "[3/6] Placing DNS (Bind9) configs..."
install -m 0644 dns/named.conf.local /etc/bind/named.conf.local
install -m 0644 dns/db.server.local /etc/bind/db.server.local
install -m 0644 dns/db.192 /etc/bind/db.192

echo "[4/6] Testing configs..."
dhcpd -t -cf /etc/dhcp/dhcpd.conf || true
named-checkconf
named-checkzone server.local /etc/bind/db.server.local

echo "[5/6] Restarting services..."
systemctl restart isc-dhcp-server || systemctl status isc-dhcp-server --no-pager
systemctl restart bind9 || systemctl status bind9 --no-pager

echo "[6/6] Applying firewall rules..."
bash firewall/firewall.sh
iptables-save > /etc/iptables/rules.v4

echo "Done. Verify with:
  - ip a
  - systemctl status isc-dhcp-server
  - ping server.local
  - nslookup server.local
  - iptables -L -n -v
"
