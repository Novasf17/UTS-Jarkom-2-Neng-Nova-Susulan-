
# UTS Jaringan Komputer 2 — DHCP, DNS, Firewall (Ubuntu Server)
**Nama:** Neng Nova  
**Kelas:** Karyawan Online  
**Topologi:** VirtualBox (Server + Client, jaringan Host-Only/Internal)

---

## 🎯 Tujuan
Membangun server Ubuntu yang menjalankan:
1) DHCP Server (isc-dhcp-server)  
2) DNS Server (Bind9) dengan domain lokal `server.local`  
3) Firewall (iptables) — membatasi akses sesuai ketentuan

> Catatan: IP contoh yang dipakai di dokumen ini bisa kamu sesuaikan.  
> - Server: `192.168.10.10/24`  
> - Gateway: `192.168.10.1`  
> - Subnet: `192.168.10.0/24`  
> - Interface server (contoh): `enp0s3`  

---

## 🧰 Persiapan
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install net-tools vim curl -y
```
Cek nama interface:
```bash
ip a
```

---

## 1) DHCP Server (isc-dhcp-server)

### Instalasi
```bash
sudo apt install isc-dhcp-server -y
```

### Konfigurasi
**/etc/default/isc-dhcp-server**
```
INTERFACESv4="enp0s3"
```
> Ganti `enp0s3` sesuai hasil `ip a` di server kamu.

**/etc/dhcp/dhcpd.conf**
```conf
default-lease-time 600;
max-lease-time 7200;
authoritative;

subnet 192.168.10.0 netmask 255.255.255.0 {
  range 192.168.10.100 192.168.10.200;
  option routers 192.168.10.1;
  option subnet-mask 255.255.255.0;
  option domain-name "server.local";
  option domain-name-servers 192.168.10.10;
}
```

### Validasi & Restart
```bash
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf
sudo systemctl restart isc-dhcp-server
sudo systemctl status isc-dhcp-server
```

---

## 2) DNS Server (Bind9)

### Instalasi
```bash
sudo apt install bind9 -y
```

### Konfigurasi
**/etc/bind/named.conf.local**
```conf
zone "server.local" {
    type master;
    file "/etc/bind/db.server.local";
};

zone "10.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192";
};
```

**/etc/bind/db.server.local**
```dns
$TTL    604800
@       IN      SOA     server.local. root.server.local. (
                        2         ; Serial
                        604800    ; Refresh
                        86400     ; Retry
                        2419200   ; Expire
                        604800 )  ; Negative Cache TTL
;
@       IN      NS      server.local.
@       IN      A       192.168.10.10
server  IN      A       192.168.10.10
www     IN      A       192.168.10.10
```

**/etc/bind/db.192**
```dns
$TTL    604800
@       IN      SOA     server.local. root.server.local. (
                        2
                        604800
                        86400
                        2419200
                        604800 )
;
@       IN      NS      server.local.
10      IN      PTR     server.local.
```

### Validasi & Restart
```bash
sudo named-checkconf
sudo named-checkzone server.local /etc/bind/db.server.local
sudo systemctl restart bind9
sudo systemctl status bind9
```

### Uji Coba
```bash
ping -c 3 server.local
nslookup server.local
dig server.local
```

---

## 3) Firewall (iptables)

### Aturan (filter)
**firewall/firewall.sh**
```bash
#!/bin/bash
# Reset rules
iptables -F

# Terima loopback & koneksi yang sudah established
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Izinkan dari subnet internal
iptables -A INPUT -s 192.168.10.0/24 -j ACCEPT

# Buka port layanan penting
iptables -A INPUT -p tcp --dport 22 -j ACCEPT   # SSH
iptables -A INPUT -p tcp --dport 80 -j ACCEPT   # HTTP
iptables -A INPUT -p tcp --dport 443 -j ACCEPT  # HTTPS

# Drop ICMP dari luar subnet
iptables -A INPUT -p icmp -s ! 192.168.10.0/24 -j DROP

# Drop sisanya
iptables -A INPUT -j DROP
```

Jalankan:
```bash
sudo bash firewall/firewall.sh
sudo iptables -L -n -v
```

> Opsional (persisten): install `iptables-persistent`
```bash
sudo apt install iptables-persistent -y
sudo sh -c 'iptables-save > /etc/iptables/rules.v4'
```

---

## 4) Testing Akhir
1. **DHCP**: Client VM (jaringan sama) harus dapat IP 192.168.10.100–200.  
2. **DNS**: `ping server.local` resolve ke `192.168.10.10`.  
3. **Firewall**: Ping dari luar subnet ditolak, tapi port 22/80/443 terbuka dari internal.

---

## 5) Struktur Repo yang Direkomendasikan
```
UTS_Jarkom2_DHCP_DNS_Firewall/
│
├── dhcp/
│   └── dhcpd.conf
│
├── dns/
│   ├── named.conf.local
│   ├── db.server.local
│   └── db.192
│
├── firewall/
│   └── firewall.sh
│
├── docs/
│   └── laporan.md
│
└── README.md
```

---

## 6) Troubleshooting Singkat
- **Service DHCP failed** → Cek `sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf` dan interface di `/etc/default/isc-dhcp-server`.
- **DNS tidak resolve** → Cek `sudo named-checkconf`, `named-checkzone`, dan pastikan client memakai DNS server `192.168.10.10`.
- **Client tidak dapat IP** → Pastikan mode jaringan VirtualBox **Host-Only / Internal** dan NIC client menyalakan DHCP dari server (bukan NAT).

---

## 7) Lisensi
Bebas dipakai untuk keperluan akademik. Sertakan kredit ke pemilik repo.
