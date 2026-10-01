# 1. Install apache2-utils untuk membuat berkas kredensial
apt-get update && apt-get install -y apache2-utils

# 2. Buat direktori /admin dan dokumen rahasia
mkdir -p /var/www/html/admin
echo "<h1>Dokumen Rahasia Sindikat</h1>" > /var/www/html/admin/index.html

# 3. Generate berkas .htpasswd berisi kredensial terenkripsi
htpasswd -c -b /etc/apache2/.htpasswd prabs "pakar_pinter_jadi_gob***"

# 4. Tambahkan direktif Basic Authentication pada VirtualHost penny.conf
cat << 'EOF' > /etc/apache2/sites-available/penny.conf
<VirtualHost *:80>
    ServerName www.K21.com
    ServerAlias penny.K21.com
    DocumentRoot /var/www/html

    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    # Proteksi Basic Auth untuk path /admin
    <Directory /var/www/html/admin>
        AuthType Basic
        AuthName "Restricted Area"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
    </Directory>
</VirtualHost>
EOF

# 5. Aktifkan konfigurasi & restart layanan Apache
a2dissite 000-default.conf 2>/dev/null
a2ensite penny.conf
a2enmod auth_basic
service apache2 restart

# 6. Menguji
curl -i http://www.K21.com/admin/
curl -i -u prabs:'pakar_pinter_jadi_gob***' http://www.K21.com/admin/



