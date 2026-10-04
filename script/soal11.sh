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



# ISI STEUP PENNY FIX 


# Isi setup_penny.sh (vault-proxy)
#!/bin/bash
set -e

if ! dpkg -l | grep -qw "^ii  apache2 "; then
    apt -o Acquire::Check-Valid-Until=false update
    apt install -y apache2
fi

a2enmod proxy
a2enmod proxy_http
a2enmod proxy_balancer
a2enmod lbmethod_byrequests
a2enmod headers
a2enmod rewrite

cat > /etc/apache2/sites-available/vault-proxy.conf << 'EOF'
<Proxy "balancer://vaultcluster">
    BalancerMember "http://10.74.1.4"
    BalancerMember "http://10.74.1.5"
</Proxy>

<VirtualHost *:80>
    ServerName penny.K21.com

    RewriteEngine On
    RewriteCond %{REMOTE_ADDR} (.+)
    RewriteRule .* - [E=REAL_IP:%1]

    ProxyPreserveHost On
    RequestHeader set X-Real-IP %{REAL_IP}e

    ProxyPass "/" "balancer://vaultcluster/"
    ProxyPassReverse "/" "balancer://vaultcluster/"

    ErrorLog ${APACHE_LOG_DIR}/vault-proxy-error.log
    CustomLog ${APACHE_LOG_DIR}/vault-proxy-access.log combined
</VirtualHost>
EOF

a2ensite vault-proxy.conf
a2dissite 000-default.conf 2>/dev/null || true

apache2ctl configtest
service apache2 restart

# daftarkan setup_penny.sh di .bashrc
cat <<EOF > /root/.bashrc
echo "nameserver 10.74.1.2" > /etc/resolv.conf
echo "nameserver 10.74.1.3" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf
chmod +x /root/setup_penny.sh
./setup_penny.sh
EOF

 
# isi setup_obladi.sh dan setup_desmond.sh
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
    LogFormat "%h Host:%{Host}i X-Real-IP:%{X-Real-IP}i \"%r\" %>s" proxytest
    CustomLog ${APACHE_LOG_DIR}/vault-access.log proxytest
</VirtualHost>
EOF

a2ensite vault.conf
a2dissite 000-default.conf 2>/dev/null || true

apache2ctl configtest
service apache2 restart

# dafrtarkan setup_obladi.sh di .bashrc
cat <<EOF > /root/.bashrc
echo "nameserver 10.74.1.2" > /etc/resolv.conf
echo "nameserver 10.74.1.3" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf
chmod +x /root/setup_obladi.sh
./setup_obladi.sh
EOF

# daftarkan setup_desmond.sh di .bashrc
cat <<EOF > /root/.bashrc
echo "nameserver 10.74.1.2" > /etc/resolv.conf
echo "nameserver 10.74.1.3" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf
chmod +x /root/setup_desmond.sh
./setup_desmond.sh
EOF






# isi setup_abbey.sh (core-proxy)
#!/bin/bash
set -e

if ! dpkg -l | grep -qw "^ii  apache2 "; then
    apt -o Acquire::Check-Valid-Until=false update
    apt install -y apache2
fi

a2enmod proxy
a2enmod proxy_http
a2enmod proxy_balancer
a2enmod lbmethod_byrequests
a2enmod headers

cat > /etc/apache2/sites-available/core-proxy.conf << 'EOF'
<Proxy "balancer://corecluster">
    BalancerMember "http://10.74.1.6"
    BalancerMember "http://10.74.1.7"
</Proxy>

<VirtualHost *:80>
    ServerName abbey.K21.com

    RewriteEngine On
    RewriteCond %{REMOTE_ADDR} (.+)
    RewriteRule .* - [E=REAL_IP:%1]

    ProxyPreserveHost On
    RequestHeader set X-Real-IP %{REAL_IP}e

    ProxyPass "/" "balancer://corecluster/"
    ProxyPassReverse "/" "balancer://corecluster/"

    ErrorLog ${APACHE_LOG_DIR}/core-proxy-error.log
    CustomLog ${APACHE_LOG_DIR}/core-proxy-access.log combined
</VirtualHost>
EOF

a2ensite core-proxy.conf
a2dissite 000-default.conf 2>/dev/null || true

apache2ctl configtest
service apache2 restart

# daftarkan setup_abbey.sh di .bashrc
cat <<EOF > /root/.bashrc
echo "nameserver 10.74.1.2" > /etc/resolv.conf
echo "nameserver 10.74.1.3" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf
chmod +x /root/setup_abbey.sh
./setup_abbey.sh
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

# daftarkan setup_molly.sh di .bashrc
cat <<EOF > /root/.bashrc
echo "nameserver 10.74.1.2" > /etc/resolv.conf
echo "nameserver 10.74.1.3" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf
chmod +x /root/setup_molly.sh
./setup_molly.sh
EOF

# daftarkan setup_oblada.sh di .bashrc
cat <<EOF > /root/.bashrc
echo "nameserver 10.74.1.2" > /etc/resolv.conf
echo "nameserver 10.74.1.3" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf
chmod +x /root/setup_oblada.sh
./setup_oblada.sh
EOF



# ============ OBLADI DESMOND (core) ================
# CONSOLE OBLADI & DESMOND
tail -f /var/log/apache2/vault-access.log
wc -l /var/log/apache2/vault-access.log

# CONSOLE OBLADI & DESMOND
for i in {1..10}; do curl -s http://penny.K21.com/arsip/ > /dev/null; done
for i in {1..10}; do curl -s http://penny.K21.com/ | grep "Server IP"; done

# ============ PEMBUKTIAN MOLLY OBLADA (core) ==============
# BAGIAN A: Bukti forwarding Host & X-Real-IP
# CONSOLE MOLLY & OBLADA
cat << 'EOF' > /var/www/core/headers.php
<?php
echo "Host yang diterima backend: " . $_SERVER['HTTP_HOST'] . "<br>\n";
echo "X-Real-IP yang diterima backend: " . ($_SERVER['HTTP_X_REAL_IP'] ?? '-') . "<br>\n";
echo "Remote Addr (dari sudut pandang backend): " . $_SERVER['REMOTE_ADDR'] . "<br>\n";
echo "Server IP (backend yang menjawab): " . $_SERVER['SERVER_ADDR'] . "<br>\n";
EOF

# CONSOLE SELAIN MOLLY & OBLADA 
curl http://abbey.K21.com/headers
