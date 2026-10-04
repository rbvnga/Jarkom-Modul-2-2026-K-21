# yang semula setup_abbey.sh memakai apache di ubah memakai nginx
```bash
#!/bin/bash
set -e

# --- Install Nginx (Soal 11: Abbey memakai Nginx) ---
if ! dpkg -l | grep -qw "^ii  nginx "; then
    apt -o Acquire::Check-Valid-Until=false update
    apt install -y nginx
fi

# --- Pastikan Apache tidak ikut memakai port 80 ---
if [ -e /etc/init.d/apache2 ]; then
    service apache2 stop 2>/dev/null || true
fi

# --- Folder dan file untuk /orion (Soal 15, murni statis) ---
mkdir -p /var/www/orion
cat << 'EOF' > /var/www/orion/index.html
<h1>Orion Static Gateway</h1>
<p>Halaman ini murni statis, disajikan langsung oleh Abbey.</p>
EOF

# --- Konfigurasi Nginx Abbey ---
cat > /etc/nginx/sites-available/core-proxy << 'EOF'
upstream corecluster {
    server 10.74.1.6;
    server 10.74.1.7;
}

# Soal 13: akses ke abbey.K21.com atau IP 10.74.2.2 -> redirect sementara 302
server {
    listen 80 default_server;
    server_name abbey.K21.com 10.74.2.2;
    return 302 http://static.K21.com$request_uri;
}

# Gerbang utama (nama kanonik static.K21.com)
server {
    listen 80;
    server_name static.K21.com;

    access_log /var/log/nginx/core-proxy-access.log;
    error_log  /var/log/nginx/core-proxy-error.log;

    # Soal 15: /orion murni statis, tanpa PHP dan tanpa proxy
    location /orion/ {
        alias /var/www/orion/;
        index index.html;
    }
    location = /orion {
        return 301 /orion/;
    }

    # Soal 11: reverse proxy ke area core + forwarding header
    location / {
        proxy_pass http://corecluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

ln -sf /etc/nginx/sites-available/core-proxy /etc/nginx/sites-enabled/core-proxy
rm -f /etc/nginx/sites-enabled/default

# --- Restart layanan ---
nginx -t
service nginx restart

# --- Self-test ---
sleep 1
echo "302 abbey.K21.com : $(curl -s -o /dev/null -w '%{http_code}' -H 'Host: abbey.K21.com' http://127.0.0.1/)"
echo "302 via IP        : $(curl -s -o /dev/null -w '%{http_code}' -H 'Host: 10.74.2.2' http://127.0.0.1/)"
echo "200 /orion/       : $(curl -s -o /dev/null -w '%{http_code}' -H 'Host: static.K21.com' http://127.0.0.1/orion/)"
echo "200 proxy core    : $(curl -s -o /dev/null -w '%{http_code}' -H 'Host: static.K21.com' http://127.0.0.1/)"
root@abbey:~# cat setup_abbey.sh
#!/bin/bash
set -e

# --- Install Nginx (Soal 11: Abbey memakai Nginx) ---
if ! dpkg -l | grep -qw "^ii  nginx "; then
    apt -o Acquire::Check-Valid-Until=false update
    apt install -y nginx
fi

# --- Pastikan Apache tidak ikut memakai port 80 ---
if [ -e /etc/init.d/apache2 ]; then
    service apache2 stop 2>/dev/null || true
fi

# --- Folder dan file untuk /orion (Soal 15, murni statis) ---
mkdir -p /var/www/orion
cat << 'EOF' > /var/www/orion/index.html
<h1>Orion Static Gateway</h1>
<p>Halaman ini murni statis, disajikan langsung oleh Abbey.</p>
EOF

# --- Konfigurasi Nginx Abbey ---
cat > /etc/nginx/sites-available/core-proxy << 'EOF'
upstream corecluster {
    server 10.74.1.6;
    server 10.74.1.7;
}

# Soal 13: akses ke abbey.K21.com atau IP 10.74.2.2 -> redirect sementara 302
server {
    listen 80 default_server;
    server_name abbey.K21.com 10.74.2.2;
    return 302 http://static.K21.com$request_uri;
}

# Gerbang utama (nama kanonik static.K21.com)
server {
    listen 80;
    server_name static.K21.com;

    access_log /var/log/nginx/core-proxy-access.log;
    error_log  /var/log/nginx/core-proxy-error.log;

    # Soal 15: /orion murni statis, tanpa PHP dan tanpa proxy
    location /orion/ {
        alias /var/www/orion/;
        index index.html;
    }
    location = /orion {
        return 301 /orion/;
    }

    # Soal 11: reverse proxy ke area core + forwarding header
    location / {
        proxy_pass http://corecluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

ln -sf /etc/nginx/sites-available/core-proxy /etc/nginx/sites-enabled/core-proxy
rm -f /etc/nginx/sites-enabled/default

# --- Restart layanan ---
nginx -t
service nginx restart

# --- Self-test ---
sleep 1
echo "302 abbey.K21.com : $(curl -s -o /dev/null -w '%{http_code}' -H 'Host: abbey.K21.com' http://127.0.0.1/)"
echo "302 via IP        : $(curl -s -o /dev/null -w '%{http_code}' -H 'Host: 10.74.2.2' http://127.0.0.1/)"
echo "200 /orion/       : $(curl -s -o /dev/null -w '%{http_code}' -H 'Host: static.K21.com' http://127.0.0.1/orion/)"
echo "200 proxy core    : $(curl -s -o /dev/null -w '%{http_code}' -H 'Host: static.K21.com' http://127.0.0.1/)"

```


service bind9 status        # di prab dan tedd
service nginx status        # abbey, oblada, molly
service apache2 status      # penny, obladi, desmond
ls /etc/init.d/             # lihat nama service yang tersedia            

# Cek Jaringan dan NAT (dari klien)
ip -br a
ping -c 2 10.74.4.1          # gateway
ping -c 2 10.74.1.2          # prab, lintas segmen
ping -c 2 8.8.8.8            # internet via NAT

# DNS (soal 4-8, 17, 19)
# dari client
cat /etc/resolv.conf                       # urutan: prab, tedd, 192.168.122.1
dig abbey.K21.com +noall +answer           # harus 10.74.2.2, bukan IP fiktif
dig K21.com SOA +short
dig alpha.K21.com TXT +short
dig -x 10.74.2.2 +short                    # reverse
dig @10.74.1.3 K21.com SOA +short          # tedd sinkron, serial sama prab
curl -s http://outbound.K21.com | head -5  # soal 19


# Web dan proxy (soal 9-15)
# di client
curl -I http://penny.K21.com               # 301 ke www
curl -I http://abbey.K21.com               # 302 ke static
curl -I http://www.K21.com/admin           # 401 tanpa kredensial


curl -i http://core.K21.com/
curl -i http://core.K21.com/profil
curl -i http://core.K21.com/profil.php
for i in 1 2 3 4; do curl -s http://core.K21.com/ | grep "Server IP"; done



curl -i -u prabs:'pakar_pinter_jadi_gob***' http://www.K21.com/admin/   # 200 ???
curl http://www.K21.com/eternal/           # PHP dirender
curl http://static.K21.com/orion/          # statis
curl http://vault.K21.com/arsip/           # autoindex
curl http://core.K21.com/profil            # URL bersih

# nomor 13
curl -I http://penny.K21.com/
curl -I http://10.74.3.2/

curl -I http://abbey.K21.com/
curl -I http://10.74.2.2/
