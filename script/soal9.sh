# 1. Update repositori & install Apache2
apt-get update && apt-get install -y apache2

# 2. Buat folder /arsip/ dan beberapa file sampel
mkdir -p /var/www/html/arsip
echo "Dokumen Rahasia Vault 1" > /var/www/html/arsip/dokumen1.txt
echo "Laporan Keuangan" > /var/www/html/arsip/laporan.pdf
touch /var/www/html/arsip/backup.zip

# 3. Buat VirtualHost dengan opsi +Indexes untuk /arsip/
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
</VirtualHost>
EOF

# 4. Aktifkan modul, aktifkan site, & restart Apache
a2enmod autoindex
a2ensite vault.conf
a2dissite 000-default.conf
service apache2 restart

# 1. Set DNS Resolver ke DNS Master & Slave
cat << 'EOF' > /etc/resolv.conf
nameserver 10.74.1.2
nameserver 10.74.1.3
EOF

# 2. Pengujian resolusi domain & tes akses autoindex
host vault.K21.com
curl -i http://vault.K21.com/arsip/

