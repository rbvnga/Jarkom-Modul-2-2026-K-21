# Install Apache di penny
apt update
apt install apache2 -y

# Aktifkan modul proxy
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_balancer
a2enmod lbmethod_byrequests

# Buat virtual host untuk reverse proxy
nano /etc/apache2/sites-available/vault-proxy.conf

<Proxy "balancer://vaultcluster">
    BalancerMember "http://10.74.1.4"
    BalancerMember "http://10.74.1.5"
</Proxy>

<VirtualHost *:80>
    ServerName penny.K21.com

    ProxyPreserveHost On
    ProxyPass "/" "balancer://vaultcluster/"
    ProxyPassReverse "/" "balancer://vaultcluster/"

    ErrorLog ${APACHE_LOG_DIR}/vault-proxy-error.log
    CustomLog ${APACHE_LOG_DIR}/vault-proxy-access.log combined
</VirtualHost>

# Aktifkan site dan restart Apache
a2ensite vault-proxy.conf
a2dissite 000-default.conf    # opsional, kalau default site tidak dipakai
apache2ctl configtest
service apache2 restart


# PEMBAHARUAN DI SETUP_PRAB
cat <<EOF > /etc/bind/jarkom/K21.com
$TTL    604800
@       IN      SOA     prab.K21.com. root.K21.com. (
                        2026093002      ; Serial
                        604800          ; Refresh
                        86400           ; Retry
                        2419200         ; Expire
                        604800 )        ; Negative Cache TTL
;
@       IN      NS      prab.K21.com.
@       IN      NS      tedd.K21.com.
@       IN      A       10.74.3.2
prab    IN      A       10.74.1.2
tedd    IN      A       10.74.1.3
alpha   IN      A       10.74.4.2
beta    IN      A       10.74.4.3
gamma   IN      A       10.74.4.4
delta   IN      A       10.74.5.2
epsilon IN      A       10.74.5.3
abbey   IN      A       10.74.2.2
penny   IN      A       10.74.3.2
obladi  IN      A       10.74.1.4
desmond IN      A       10.74.1.5
oblada  IN      A       10.74.1.6
molly   IN      A       10.74.1.7
EOF


# di tedd, kalau mau paksa transfer ulang #
rndc retransfer K21.com
dig @10.74.1.3 penny.K21.com

named-checkconf
named-checkzone K21.com /etc/bind/jarkom/K.com
service bind9 restart




# UNTUK rndc retransfer K21.com === TEDD, JIKA PRAB ADA PERUBAHAN DI SETUP NYA
rndc retransfer K21.com

# ========= MASUKIN SETUP PENNY =====
cat <<EOF > /root/.bashrc
echo "nameserver 10.74.1.2" > /etc/resolv.conf
echo "nameserver 10.74.1.3" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf
chmod +x /root/setup_penny.sh
./setup_penny.sh
EOF


# SETUP OBLADI 
# isi setup obladi.sh DAN SETUP_DESMOND.SH
#!/bin/bash
set -e

if ! dpkg -l | grep -qw "^ii  apache2 "; then
    apt -o Acquire::Check-Valid-Until=false update
    apt install -y apache2
fi

mkdir -p /var/www/html/arsip
echo "Dokumen Rahasia Vault 1" > /var/www/html/arsip/dokumen1.txt
echo "Laporan Keuangan" > /var/www/html/arsip/laporan.pdf
touch /var/www/html/arsip/backup.zip

cat << 'EOF' > /etc/apache2/sites-available/vault.conf
<VirtualHost *:80>
    ServerName vault.K21.com
    ServerAlias obladi.K21.com desmond.K21.com
    DocumentRoot /var/www/html

    <Directory /var/www/html/arsip>
        Options +Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/vault-error.log
    CustomLog ${APACHE_LOG_DIR}/vault-access.log combined
</VirtualHost>
EOF

a2ensite vault.conf
a2dissite 000-default.conf 2>/dev/null || true

apache2ctl configtest
service apache2 restart

# OBLADI

cat <<EOF > /root/.bashrc
echo "nameserver 10.74.1.2" > /etc/resolv.conf
echo "nameserver 10.74.1.3" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf
chmod +x /root/setup_obladi.sh
./setup_obladi.sh
EOF

# DESMOND

cat <<EOF > /root/.bashrc
echo "nameserver 10.74.1.2" > /etc/resolv.conf
echo "nameserver 10.74.1.3" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf
chmod +x /root/setup_desmond.sh
./setup_desmond.sh
EOF

# isi setup_ molly dan oblada
#!/bin/bash
set -e

apt -o Acquire::Check-Valid-Until=false update
apt install -y nginx php-fpm

PHP_VERSION=$(ls /etc/php/ | head -n1)
echo "Terdeteksi PHP versi: ${PHP_VERSION}"

mkdir -p /var/www/core

cat << 'EOF' > /var/www/core/index.php
<?php
echo "<h1>Selamat Datang di Halaman Beranda Node Core</h1>";
echo "<p>Server IP: " . $_SERVER['SERVER_ADDR'] . "</p>";
echo "<a href='/profil'>Ke Halaman Profil</a>";
?>
EOF

cat << 'EOF' > /var/www/core/profil.php
<?php
echo "<h1>Halaman Profil Node Core</h1>";
echo "<p>Ini adalah halaman profil dengan URL bersih (Clean URL).</p>";
echo "<a href='/'>Kembali ke Beranda</a>";
?>
EOF

cat << EOF > /etc/nginx/sites-available/core
server {
    listen 80;
    server_name core.K21.com oblada.K21.com molly.K21.com;
    root /var/www/core;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ \$uri.php?\$args;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php${PHP_VERSION}-fpm.sock;
    }
}
EOF

ln -sf /etc/nginx/sites-available/core /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

service php${PHP_VERSION}-fpm restart
nginx -t && service nginx restart

# MOLLY
cat <<EOF > /root/.bashrc
echo "nameserver 10.74.1.2" > /etc/resolv.conf
echo "nameserver 10.74.1.3" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf
chmod +x /root/setup_molly.sh
./setup_molly.sh
EOF

# OBLADA

cat <<EOF > /root/.bashrc
echo "nameserver 10.74.1.2" > /etc/resolv.conf
echo "nameserver 10.74.1.3" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf
chmod +x /root/setup_oblada.sh
./setup_oblada.sh
EOF




