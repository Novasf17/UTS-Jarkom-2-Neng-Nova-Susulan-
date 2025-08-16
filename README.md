# Konfigurasi DHCP, DNS, dan Firewall di Ubuntu Server

## 👩‍💻 Identitas
- Nama  : Neng Nova  
- Kelas : Karyawan Online  
- Matkul: Jaringan Komputer 2  
- Tugas : UTS / Konfigurasi DHCP, DNS, dan Firewall  

---

## 📌 Deskripsi
Repository ini berisi dokumentasi dan script konfigurasi untuk:
1. **DHCP Server** (`isc-dhcp-server`)
2. **DNS Server** (`bind9`)
3. **Firewall** (`ufw`)

Semua konfigurasi dilakukan pada **Ubuntu Server (VirtualBox)**.  
Tujuan dari tugas ini adalah memahami cara kerja layanan jaringan dasar dan manajemen akses pada server Linux.

---

## ⚙️ Konfigurasi
Konfigurasi file /etc/dhcp/dhcpd.conf:
subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.10 192.168.1.50;
    option routers 192.168.1.1;
    option domain-name-servers 192.168.1.1;
    default-lease-time 600;
    max-lease-time 7200;
}

### 1. DHCP Server
- Install paket:
  ```bash
  sudo apt update
  sudo apt install isc-dhcp-server -y

2. DNS Server

Install paket:

sudo apt install bind9 -y


Contoh konfigurasi zone di /etc/bind/named.conf.local:

zone "nova.local" {
    type master;
    file "/etc/bind/db.nova.local";
};


File /etc/bind/db.nova.local:

$TTL    604800
@       IN      SOA     ns.nova.local. root.nova.local. (
                            2         ; Serial
                       604800         ; Refresh
                        86400         ; Retry
                      2419200         ; Expire
                       604800 )       ; Negative Cache TTL
;
@       IN      NS      ns.nova.local.
ns      IN      A       192.168.1.1
www     IN      A       192.168.1.10

3. Firewall (UFW)

Aktifkan UFW:

sudo ufw enable


Atur aturan:

sudo ufw allow 22/tcp
sudo ufw allow 53
sudo ufw allow 67
sudo ufw allow 68
sudo ufw status
