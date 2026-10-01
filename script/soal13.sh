# ==========================================
# KONFIGURASI PENNY (Apache2 - Redirect 301)
# ==========================================

# 1. Aktifkan modul rewrite pada Apache
a2enmod rewrite

# 2. Tulis VirtualHost untuk domain kanonik www.K21.com dan Catch-All Redirect 301
cat << 'EOF' > /etc/apache2/sites-available/penny.conf
# VirtualHost Utama Canonical (www.K21.com)
<VirtualHost *:80>
    ServerName www.K21.com
    DocumentRoot /var/www/html

    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    <Directory /var/www/html/admin>
        AuthType Basic
        AuthName "Restricted Area"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
    </Directory>
</VirtualHost>

# VirtualHost Catch-All (IP 10.74.3.2 & penny.K21.com -> Redirect 301)
<VirtualHost *:80>
    ServerName penny.K21.com
    ServerAlias 10.74.3.2

    RewriteEngine On
    RewriteCond %{HTTP_HOST} !^www\.K21\.com$ [NC]
    RewriteRule ^(.*)$ http://www.K21.com$1 [R=301,L]
</VirtualHost>
EOF

# 3. Aktifkan site & restart Apache
a2dissite 000-default.conf 2>/dev/null
a2ensite penny.conf
service apache2 restart
