# 1. Konfigurasi tedd sebagai Slave DNS
cat << 'EOF' > /etc/bind/named.conf.local
zone "K21.com" {
    type slave;
    file "/var/cache/bind/db.K21.com";
    masters { 10.74.1.2; };
};
EOF

# 2. Restart layanan BIND9
service bind9 restart

# 3. Cek apakah file hasil zone transfer dari prab sudah diterima
ls -l /var/cache/bind/db.K21.com

# 4. Uji otorisasi pengiriman seluruh record zone (AXFR) dari prab
dig @10.74.1.2 K21.com AXFR
