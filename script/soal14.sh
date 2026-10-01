
# perbarui isi setup_desmond.sh & setup_obladi.sh (vault-proxy)
#!/bin/bash
set -e

if ! dpkg -l | grep -qw "^ii  apache2 "; then
    apt -o Acquire::Check-Valid-Until=false update
    apt install -y apache2
fi

a2enmod remoteip

mkdir -p /var/www/html/arsip
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


# penambahan isi modul setup_abbey.sh (core-proxy)
# a2enmod rewrite
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

 
# perbarui isi setup_oblada.sh dan setup_molly.sh (core-proxy)
#!/bin/bash
set -e

apt -o Acquire::Check-Valid-Until=false update
apt install -y nginx php-fpm

PHP_VERSION=$(ls /etc/php/ | head -n1)
echo "Terdeteksi PHP versi: ${PHP_VERSION}"

mkdir -p /var/www/core

cat << 'EOF' > /var/www/core/index.php
<?php
echo "<h1>Selamat Datang di Halaman Beranda Node Core</h1>\n";
echo "<p>Server IP: " . $_SERVER['SERVER_ADDR'] . "</p>\n";
echo "<p>Remote Addr (klien asli): " . $_SERVER['REMOTE_ADDR'] . "</p>\n";
echo "<a href='/profil'>Ke Halaman Profil</a>\n";
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

    set_real_ip_from 10.74.2.2;
    real_ip_header X-Real-IP;

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
