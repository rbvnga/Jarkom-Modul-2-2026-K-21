# Jarkom-Modul-2-2026-K-21

| Nama                          | NRP        |
| ----------------------------- | ---------- |
| Revalinda Bunga Nayla Laksono | 5027251011 |
| Najla Tufailah                | 5027251078 |

## 1
**rootkit harus merentangkan ke 5 gerbang utama (Switch), dengan menepatkan alamat IP dan default gateway, mulai dari para operator (alpha, beta, gamma), penjaga directory (prab, tedd), gerbang penyaring (abbey, penny), hingga repository (obladi, desmond, oblada, molly)**

<img src="assets/soal1_topologi jaringan.png">

Topologi ini dibangun dengan **rootkit** sebagai router utama yang juga terhubung dengan 5 jalur (switch) yaitu: 
1. Jalur sayap kiri, melalui Switch6, yang menghubungkan klien alpha, beta, dan gamma.
2. Jalur sayap kanan, melalui Switch7, yang menghubungkan klien delta dan epsilon.
3. Jalur gerbang penyaring pertama, melalui Switch4, yang menghubungkan klien abbey sebagai reverse proxy.
4. Jalur gerbang penyaring kedua, melalui Switch5, yang menghubungkan klien penny sebagai reverse proxy.
5. Jalur repository dan directory, melalui Switch1 yang diteruskan ke Switch2 dan Switch3, yang menghubungkan prab, tedd, obladi, desmond, oblada, dan molly.

### Konfigurasi Jaringan
- rootkit
```
auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
  address 10.74.1.1
  netmask 255.255.255.0

auto eth2
iface eth2 inet static
  address 10.74.2.1
  netmask 255.255.255.0

auto eth3
iface eth3 inet static
  address 10.74.3.1
  netmask 255.255.255.0

auto eth4
iface eth4 inet static
  address 10.74.4.1
  netmask 255.255.255.0

auto eth5
iface eth5 inet static
  address 10.74.5.1
  netmask 255.255.255.0
```
- prab
```
auto eth0
iface eth0 inet static
    address 10.74.1.2
    netmask 255.255.255.0
    gateway 10.74.1.1
```

- tedd

```
auto eth0
iface eth0 inet static
    address 10.74.1.3
    netmask 255.255.255.0
    gateway 10.74.1.1
```

- obladi
```
auto eth0
iface eth0 inet static
    address 10.74.1.4
    netmask 255.255.255.0
    gateway 10.74.1.1
```
- desmond
```
auto eth0
iface eth0 inet static
    address 10.74.1.5
    netmask 255.255.255.0
    gateway 10.74.1.1
```
- oblada
```
auto eth0
iface eth0 inet static
    address 10.74.1.6
    netmask 255.255.255.0
    gateway 10.74.1.1
```
- molly
```
auto eth0
iface eth0 inet static
    address 10.74.1.7 
    netmask 255.255.255.0
    gateway 10.74.1.1
```
- abbey
```
auto eth0
iface eth0 inet static
    address 10.74.2.2
    netmask 255.255.255.0
    gateway 10.74.2.1
```
- penny
```
auto eth0
iface eth0 inet static
    address 10.74.3.2
    netmask 255.255.255.0
    gateway 10.74.3.1
```
- alpha
```
auto eth0
iface eth0 inet static
    address 10.74.4.2
    netmask 255.255.255.0
    gateway 10.74.4.1
```
- beta
```
auto eth0
iface eth0 inet static
    address 10.74.4.3
    netmask 255.255.255.0
    gateway 10.74.4.1
```
- gamma
```
auto eth0
iface eth0 inet static
    address 10.74.4.4
    netmask 255.255.255.0
    gateway 10.74.4.1
```
- delta
```
auto eth0
iface eth0 inet static
    address 10.74.5.2
    netmask 255.255.255.0
    gateway 10.74.5.1
```
- epsilon
```
auto eth0
iface eth0 inet static
    address 10.74.5.3
    netmask 255.255.255.0
    gateway 10.74.5.1
```


## 2
**Membuka jalur menuju NAT dengan memastikan antar muka WAN di router rootkit aktif. Mengonfigurasi NAT agar dapat meneruskan lalu lintas keluar bagi alamat internal, sehingga semua host di dalam jaringan dapat menjangkau internet publik menggunakan IP address**
Mengkonfigurasi NAT (Netwoek Address Translation) pada rootkit dilakukan agar dapat menerjemahkan setiap alamat IP privat client menjadi alamat IP publik ketika para client ingin mengakses internet. langkah pertama adalah memastikan iptables ada dengan 
```
apt update
apt install -y iptables
```
Kemudian konfigurasi `eth0` dan NAT pada `rootkit`
```
auto eth0
iface eth0 inet dhcp
up sysctl -w net.ipv4.ip_forward=1
up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.74.0.0/16
```
Konfigurasi tersebut berfungsi untuk:
- `up` → Menjalankan perintah ini ketika interface tersebut berhasil diaktifkan.
- `eth0` → antarmuka WAN yang terhubung ke NAT.
- `ip_forward=1` → mengaktifkan penerusan paket antarjaringan.
- `MASQUERADE` → menerjemahkan IP privat client menjadi alamat IP pada eth0.
- `10.74.0.0/16` → menentukan jaringan internal yang menggunakan NAT.

### Pembuktian
Pengujian dilakukan dari client `obladi` dengan melakukan `ping` ke alamat IP `8.8.8.8` untuk memastikan client dapat terhubung ke internet melalui router `rootkit`. Penggunaan alamat IP secara langsung memastikan pengujian tidak bergantung pada proses DNS.
<img src="assets/soal1_pembuktian">

## 3
**Memastikan setiap host non-router menambahkan resolver 192.168.122.1 saat antarmukanya aktif agar akses untuk mengunduh paket isntalasi dari internet tersedia sejak awal beroprasi**
Konfigurasi dilakukan agar seluruh host pada jaringan internal dapat saling berkomunikasi antar-subnet dan dapat melakukan resolusi nama domain menggunakan DNS resolver `192.168.122.1`. <br> <br>
Setiap host dikonfigurasi menggunakan IP address sesuai subnet masing-masing dan `rootkit` sebagai default gateway. Dengan demikian, paket dari satu subnet dapat diteruskan oleh `rootkit` menuju subnet lainnya. <br> <br>
DNS resolver dikonfigurasi pada setiap host menggunakan:
```bash
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```
### pembuktian
- pengujian routing internal dilakukan dari **alpha** menuju host pada subnet lain, yaitu **abbey** dengan alamat `10.74.2.2`
<img src="assets/soal3_pembuktian.png">
- Pengujian DNS dilakukan dengan melakukan ping menggunakan nama domain:
<img src="assets/soal3_pembuktian2.png">

## 4
****
Dalam skema ini, Prab bertindak sebagai server DNS master yang memegang kendali utama, sedangkan Tedd disiapkan sebagai server DNS slave. Kehadiran Tedd memastikan kontinuitas layanan ketika Prab tidak dapat beroperasi.
## Konfigurasi Prab (DNS Master)
## Konfigurasi Tedd (DNS Slave)

## 5
****