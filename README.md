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
**ISI SOALNYA APA**

## 4

**Penjaga Direktori mulai menuliskan hukum The Mesh. Pada node prab, bangun zona <xxxx>.com sebagai authoritative dengan SOA yang menunjuk ke prab.<xxxx>.com, serta tambahkan catatan NS untuk prab.<xxxx>.com dan tedd.<xxxx>.com. Buat A record untuk prab.<xxxx>.com dan tedd.<xxxx>.com yang mengarah ke alamat IP mereka masing-masing, serta A record apex <xxxx>.com yang mengarah ke gerbang aplikasi dinamis (penny). Aktifkan fitur notify dan allow-transfer ke tedd, lalu set forwarders ke 192.168.122.1. Di node tedd, tarik zona <xxxx>.com dari master dan pastikan server menjawab secara authoritative. Setelah fondasi nama ini berdiri kokoh, perbarui urutan resolver pada seluruh Entitas non-router menjadi: IP prab, IP tedd, lalu 192.168.122.1. Verifikasi bahwa query ke domain apex maupun hostname di dalam zona dijawab dengan benar oleh prab atau tedd.**

Dalam skema ini, **Prab** bertindak sebagai **server DNS master** yang memegang kendali utama, sedangkan **Tedd** disiapkan sebagai **server DNS slave**. Kehadiran Tedd memastikan kontinuitas layanan ketika Prab tidak dapat beroperasi.

| Node | Peran | IP |
|------|-------|-----|
| Prab | DNS Master | `10.74.1.2` |
| Tedd | DNS Slave | `10.74.1.3` |
| Penny | Gerbang aplikasi dinamis | `10.74.3.2` |

---

## Konfigurasi Prab (DNS Master)

### 1. Instalasi BIND9

```bash
apt update
apt install bind9 dnsutils -y
ln -s /etc/init.d/named /etc/init.d/bind9

# Edit /etc/bind/named.conf.local untuk mendaftarkan zona
nano /etc/bind/named.conf.local
```

### 2. Mendaftarkan Zona

Isi `/etc/bind/named.conf.local`:

```
zone "K21.com" {
    type master;
    file "/etc/bind/jarkom/K21.com";
    notify yes;
    allow-transfer { 10.74.1.3; };
    also-notify { 10.74.1.3; };
};
```

| Direktif | Penjelasan |
|----------|------------|
| `type master` | Prab adalah pemilik data asli zona ini. |
| `notify yes` + `also-notify` | Prab otomatis memberi tahu Tedd setiap ada perubahan zona, sehingga Tedd tidak perlu menunggu jadwal *refresh*. |
| `allow-transfer` | Membatasi siapa yang boleh menarik salinan zona. Hanya Tedd (`10.74.1.3`) yang diizinkan. Jika dibuka untuk semua orang, seluruh isi zona bisa dibaca siapa saja. |

### 3. Opsi Global BIND

Edit `/etc/bind/named.conf.options`:

```bash
nano /etc/bind/named.conf.options
```

```
options {
    directory "/var/cache/bind";
    forwarders {
        192.168.122.1;
    };
    allow-query { any; };
    dnssec-validation no;
    listen-on-v6 { any; };
};
```

- **`forwarders`**: jika ada query untuk domain di luar zona kita (misalnya `google.com`), BIND meneruskannya ke `192.168.122.1` alih-alih mencari sendiri.
- **`allow-query { any; }`**: mengizinkan semua host bertanya ke server ini.

### 4. Membuat File Zona

```bash
mkdir -p /etc/bind/jarkom

cat <<'EOF' > /etc/bind/jarkom/K21.com
$TTL    604800
@       IN      SOA     prab.K21.com. root.K21.com. (
                        2026092801      ; Serial
                        604800          ; Refresh
                        86400           ; Retry
                        2419200         ; Expire
                        604800 )        ; Negative Cache TTL
;
@       IN      NS      prab.K21.com.
@       IN      NS      tedd.K21.com.
prab    IN      A       10.74.1.2
tedd    IN      A       10.74.1.3
@       IN      A       10.74.3.2
EOF

named-checkconf
named-checkzone K21.com /etc/bind/jarkom/K21.com
service bind9 restart
```

> **Catatan:** `'EOF'` (dengan tanda kutip) dipakai agar shell tidak mengubah `$TTL` menjadi string kosong.

**Isi file zona:**

| Record | Fungsi |
|--------|--------|
| `SOA` | Data otoritatif zona: name server utama (`prab.K21.com.`), email admin (`root.K21.com.`), serta parameter *serial*, *refresh*, *retry*, *expire*, dan *negative cache TTL*. Serial harus dinaikkan setiap zona diubah agar slave tahu ada versi baru. |
| `NS` | Mendaftarkan `prab` dan `tedd` sebagai name server resmi untuk `K21.com`. |
| `A prab` / `A tedd` | Memetakan hostname name server ke IP masing-masing. |
| `@ A 10.74.3.2` | Domain utama `K21.com` mengarah ke Penny (gerbang aplikasi dinamis). |

`named-checkconf` dan `named-checkzone` memvalidasi sintaks konfigurasi dan file zona sebelum BIND direstart.

### 5. Memperbaiki Urutan Resolver di Setiap Host

```bash
cat <<EOF > /root/.bashrc
echo "nameserver 10.74.1.2" > /etc/resolv.conf
echo "nameserver 10.74.1.3" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf
EOF
```

Setiap kali shell dibuka, `/etc/resolv.conf` diatur ulang dengan urutan prioritas:

1. `10.74.1.2` (Prab, master)
2. `10.74.1.3` (Tedd, slave, sebagai cadangan jika Prab mati)
3. `192.168.122.1` (resolver luar, untuk domain di luar zona)

---

## Konfigurasi Tedd (DNS Slave)

```bash
apt update
apt install bind9 dnsutils -y
ln -s /etc/init.d/named /etc/init.d/bind9

# Edit /etc/bind/named.conf.local untuk mendaftarkan zona
nano /etc/bind/named.conf.local
```

Isi `/etc/bind/named.conf.local`:

```
zone "K21.com" {
    type slave;
    masters { 10.74.1.2; };
    file "/var/lib/bind/K21.com";
};
```

- `type slave`: Tedd hanya menyalin data zona dari master.
- `masters { 10.74.1.2; }`: sumber salinan zona adalah Prab.
- `file`: lokasi penyimpanan salinan zona hasil transfer di Tedd.

---

## Pembuktian

### Tes resolusi DNS langsung dari Prab

**1. Query domain utama**

```bash
dig K21.com
```

<img src="assets/soal3_pembuktian3.png">

- `SERVER: 10.74.1.2`: query dijawab langsung oleh Prab, bukan diteruskan ke `192.168.122.1`. Ini membuktikan urutan `resolv.conf` sudah benar.
- `aa` (*Authoritative Answer*) di flags: Prab menjawab sebagai pemilik zona, bukan sekadar cache/forward dari server lain.
- Record `A` bernilai `10.74.3.2`, sesuai dengan IP Penny (gerbang aplikasi dinamis).

**2. Query hostname name server**

```bash
dig prab.K21.com
```

<img src="assets/soal3_pembuktian4.png">

Hostname `prab.K21.com` juga dijawab dengan `aa`, dan IP-nya cocok dengan IP asli Prab (`10.74.1.2`). Ini membuktikan record `A` untuk name server sudah dikonfigurasi benar di zona.

**3. Query record NS**

```bash
dig NS K21.com
```

<img src="assets/soal3_pembuktian5.png">

- Dua record NS terdaftar untuk zona `K21.com`, yaitu `prab.K21.com` dan `tedd.K21.com`.
- `ADDITIONAL SECTION` otomatis melampirkan IP masing-masing NS (*glue records*), menunjukkan record `A` Prab dan Tedd terhubung dengan benar ke record NS-nya.
- Semua dijawab dengan `aa`, dan sumbernya `10.74.1.2` (Prab sendiri), bukan dari luar.

### Tes resolusi DNS dari Tedd

```bash
dig @10.74.1.3 K21.com
```

<img src="assets/soal3_pembuktian6.png">

- `SERVER: 10.74.1.3#53`: query dikirim dan dijawab langsung oleh Tedd (bukan diteruskan ke Prab atau forwarder luar). Ini membuktikan Tedd sudah punya salinan zona dan dapat menjawab query DNS secara mandiri.
- `aa` di flags: Tedd menganggap dirinya *authoritative* untuk `K21.com`. Ini menunjukkan zone transfer berhasil dan Tedd memiliki salinan zona yang lengkap, persis seperti Prab. Jika transfer gagal, Tedd tidak akan memiliki data zona sehingga tidak bisa menjawab dengan flag `aa`.
- `ANSWER SECTION: K21.com. → 10.74.3.2`: hasilnya identik dengan jawaban Prab (mengarah ke Penny). Ini membuktikan data di Tedd sinkron dengan data master di Prab.



## 5
**"Entitas tanpa identitas adalah anomali," pesan Rootkit. Namai semua Entitas (hostname) sesuai glosarium: rootkit, alpha, beta, gamma, delta, epsilon, prab, tedd, abbey, penny, obladi, desmond, oblada, molly, dan verifikasi bahwa setiap host mengenali hostname tersebut secara system-wide. Buat setiap domain untuk masing-masing node sesuai dengan namanya (contoh: alpha.<xxxx>.com) dan assign IP masing-masing juga. Lakukan pengecualian untuk node yang bertanggung jawab atas prab dan tedd.**