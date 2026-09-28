# Jarkom-Modul-2-2026-K-21

| Nama                          | NRP        |
| ----------------------------- | ---------- |
| Revalinda Bunga Nayla Laksono | 5027251011 |
| Najla Tufailah                | 5027251078 |

## 1
**rootkit harus merentangkan ke 5 gerbang utama (Switch), dengan menepatkan alamat IP dan default gateway, mulai dari para operator (alpha, beta, gamma), penjaga directory (prab, tedd), gerbang penyaring (abbey, penny), hingga repository (obladi, desmond, oblada, molly)**

<img width="1262" height="1182" alt="soal1_topologi" src="https://github.com/user-attachments/assets/573a9be3-2f48-4c9f-beee-8672819de3d0" />


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

## 3
**Memastikan setiap host non-router menambahkan resolver 192.168.122.1 saat antarmukanya aktif agar akses untuk mengunduh paket isntalasi dari internet tersedia sejak awal beroprasi**

## 4

