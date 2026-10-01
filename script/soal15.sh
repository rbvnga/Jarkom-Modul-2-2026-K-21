# proxy_fcgi adalah modul yang memungkinkan Apache meneruskan eksekusi .php ke proses PHP-FPM lewat protokol FastCGI — mirip konsepnya dengan yang dipakai Nginx di oblada/molly, tapi versi Apache.

# HASIL MEMPERBARUI SETUP_PENNY.SH
#!/bin/bash
set -e

# --- Install Apache ---
if ! dpkg -l | grep -qw "^ii  apache2 "; then
    apt -o Acquire::Check-Valid-Until=false update
    apt install -y apache2
fi

# --- Install PHP-FPM untuk path /eternal (Soal 15) ---
if ! dpkg -l | grep -q "php.*-fpm"; then
    apt -o Acquire::Check-Valid-Until=false update
    apt install -y php-fpm
fi

PHP_VERSION=$(ls /etc/php/ | head -n1)
echo "Terdeteksi PHP versi: ${PHP_VERSION}"

# --- Aktifkan modul Apache yang dibutuhkan ---
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_balancer
a2enmod lbmethod_byrequests
a2enmod headers
a2enmod rewrite
a2enmod proxy_fcgi

# --- Buat folder dan file untuk /eternal (Soal 15) ---
mkdir -p /var/www/eternal
cat << 'EOF' > /var/www/eternal/index.php
<?php
echo "<h1>Eternal Vault</h1>\n";
echo "<p>Halaman ini dirender oleh PHP di node Penny.</p>\n";
echo "<p>Waktu server: " . date("Y-m-d H:i:s") . "</p>\n";
?>
EOF

# --- Tulis konfigurasi VirtualHost Penny ---
cat > /etc/apache2/sites-available/vault-proxy.conf << EOF
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

    Alias /eternal /var/www/eternal
    <Directory /var/www/eternal>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
        DirectoryIndex index.php
    </Directory>
    <FilesMatch \.php\$>
        SetHandler "proxy:unix:/run/php/php${PHP_VERSION}-fpm.sock|fcgi://localhost"
    </FilesMatch>
    ProxyPass "/eternal" "!"

    ProxyPass "/" "balancer://vaultcluster/"
    ProxyPassReverse "/" "balancer://vaultcluster/"

    ErrorLog \${APACHE_LOG_DIR}/vault-proxy-error.log
    CustomLog \${APACHE_LOG_DIR}/vault-proxy-access.log combined
</VirtualHost>
EOF

a2ensite vault-proxy.conf
a2dissite 000-default.conf 2>/dev/null || true

# --- Restart layanan ---
apache2ctl configtest
service php${PHP_VERSION}-fpm restart
service apache2 restart


# HASIL MEMPERBARUI SETUP_ABBEY.SH
#!/bin/bash
set -e

# --- Install Apache ---
if ! dpkg -l | grep -qw "^ii  apache2 "; then
    apt -o Acquire::Check-Valid-Until=false update
    apt install -y apache2
fi

# --- Aktifkan modul Apache yang dibutuhkan ---
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_balancer
a2enmod lbmethod_byrequests
a2enmod headers
a2enmod rewrite

# --- Buat folder dan file untuk /orion (Soal 15, murni statis) ---
mkdir -p /var/www/orion
cat << 'EOF' > /var/www/orion/index.html
<h1>Orion Static Gateway</h1>
<p>Halaman ini murni statis, disajikan langsung oleh Abbey.</p>
EOF

# --- Tulis konfigurasi VirtualHost Abbey ---
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

    Alias /orion /var/www/orion
    <Directory /var/www/orion>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
    ProxyPass "/orion" "!"

    ProxyPass "/" "balancer://corecluster/"
    ProxyPassReverse "/" "balancer://corecluster/"

    ErrorLog ${APACHE_LOG_DIR}/core-proxy-error.log
    CustomLog ${APACHE_LOG_DIR}/core-proxy-access.log combined
</VirtualHost>
EOF

a2ensite core-proxy.conf
a2dissite 000-default.conf 2>/dev/null || true

# --- Restart layanan ---
apache2ctl configtest
service apache2 restart


# pembaharuan setup_obladi.sh dan setup_desmond.sh- penambahan isi ke index.html
#!/bin/bash
set -e

if ! dpkg -l | grep -qw "^ii  apache2 "; then
    apt -o Acquire::Check-Valid-Until=false update
    apt install -y apache2
fi

a2enmod remoteip

mkdir -p /var/www/html/arsip
echo "<h1>Area Vault - $(hostname)</h1><p>Static web server node.</p>" > /var/www/html/index.html
echo "Dokumen Rahasia Vault 1" > /var/www/html/arsip/dokumen1.txt
echo "Laporan Keuangan" > /var/www/html/arsip/laporan.pdf
touch /var/www/html/arsip/backup.zip

cat << 'EOF' > /etc/apache2/sites-available/vault.conf
<VirtualHost *:80>
    ServerName vault.K21.com
    ServerAlias obladi.K21.com desmond.K21.com
    DocumentRoot /var/www/html

    RemoteIPHeader X-Real-IP
    RemoteIPTrustedProxy 10.74.3.2

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