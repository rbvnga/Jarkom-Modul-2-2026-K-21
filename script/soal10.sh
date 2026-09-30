# Install Nginx & PHP-FPM
apt-get update && apt-get install -y nginx php-fpm

# Buat direktori & file PHP (Beranda & Profil)
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

# Konfigurasi Server Block Nginx + URL Rewrite + Socket PHP 8.4
cat << 'EOF' > /etc/nginx/sites-available/core
server {
    listen 80;
    server_name core.K21.com oblada.K21.com molly.K21.com;
    root /var/www/core;
    index index.php index.html;

    location / {
        try_files $uri $uri/ $uri.php?$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }
}
EOF

# Aktifkan Site & Restart Service
ln -sf /etc/nginx/sites-available/core /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
service php8.4-fpm restart
nginx -t && service nginx restart

# Set Resolver
cat << 'EOF' > /etc/resolv.conf
nameserver 10.74.1.2
nameserver 10.74.1.3
EOF

# Pengujian Akses Hostname Beranda & Profil
curl -i http://core.K21.com/
curl -i http://core.K21.com/profil
