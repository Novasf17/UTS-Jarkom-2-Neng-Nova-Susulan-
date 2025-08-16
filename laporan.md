
# Laporan Singkat UTS Jaringan Komputer 2
Nama: Neng Nova  
Topik: DHCP, DNS, Firewall di Ubuntu (VirtualBox)

## Ringkasan
Konfigurasi server yang dibuat meliputi DHCP untuk pemberian IP otomatis, DNS lokal `server.local` dengan Bind9, serta aturan firewall menggunakan iptables.

## Langkah Utama
1. Instal paket: isc-dhcp-server, bind9, iptables-persistent.
2. Atur DHCP pada subnet 192.168.10.0/24 (range 192.168.10.100–200).
3. Atur DNS zona forward `server.local` dan reverse `10.168.192.in-addr.arpa`.
4. Terapkan aturan firewall: allow 22/80/443, drop ICMP dari luar subnet.

## Pengujian
- Client menerima IP dari DHCP.
- `ping server.local` mengarah ke 192.168.10.10.
- Aturan firewall aktif (`iptables -L -n -v`).

## Catatan
Jika servis gagal, periksa syntax file konfigurasi dan nama interface.
