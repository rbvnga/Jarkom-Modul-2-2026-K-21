# === KONFIGURASI MASTER (PRAB) ===
cat << 'EOF' >> /etc/bind/named.conf.local

zone "1.74.10.in-addr.arpa" {
    type master;
    file "/etc/bind/jarkom/1.74.10.in-addr.arpa";
    notify yes;
    allow-transfer { 10.74.1.3; };
};

zone "2.74.10.in-addr.arpa" {
    type master;
    file "/etc/bind/jarkom/2.74.10.in-addr.arpa";
    notify yes;
    allow-transfer { 10.74.1.3; };
};

zone "3.74.10.in-addr.arpa" {
    type master;
    file "/etc/bind/jarkom/3.74.10.in-addr.arpa";
    notify yes;
    allow-transfer { 10.74.1.3; };
};
EOF

cat << 'EOF' > /etc/bind/jarkom/1.74.10.in-addr.arpa
$TTL    604800
@       IN      SOA     prab.K21.com. root.K21.com. (
                        2026093001
                        604800
                        86400
                        2419200
                        604800 )
;
@       IN      NS      prab.K21.com.
@       IN      NS      tedd.K21.com.

4       IN      PTR     obladi.K21.com.
5       IN      PTR     desmond.K21.com.
6       IN      PTR     oblada.K21.com.
7       IN      PTR     molly.K21.com.
EOF

cat << 'EOF' > /etc/bind/jarkom/2.74.10.in-addr.arpa
$TTL    604800
@       IN      SOA     prab.K21.com. root.K21.com. (
                        2026093001
                        604800
                        86400
                        2419200
                        604800 )
;
@       IN      NS      prab.K21.com.
@       IN      NS      tedd.K21.com.

2       IN      PTR     abbey.K21.com.
EOF

cat << 'EOF' > /etc/bind/jarkom/3.74.10.in-addr.arpa
$TTL    604800
@       IN      SOA     prab.K21.com. root.K21.com. (
                        2026093001
                        604800
                        86400
                        2419200
                        604800 )
;
@       IN      NS      prab.K21.com.
@       IN      NS      tedd.K21.com.

2       IN      PTR     penny.K21.com.
EOF

named-checkconf /etc/bind/named.conf.local
service bind9 restart

# === KONFIGURASI SLAVE (TEDD) ===
cat << 'EOF' >> /etc/bind/named.conf.local

zone "1.74.10.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/db.1.74.10";
    masters { 10.74.1.2; };
};

zone "2.74.10.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/db.2.74.10";
    masters { 10.74.1.2; };
};

zone "3.74.10.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/db.3.74.10";
    masters { 10.74.1.2; };
};
EOF

service bind9 restart
ls -la /var/cache/bind/

# === PENGUJIAN CLIENT (ALPHA / BETA) ===
host 10.74.2.2 10.74.1.2
host 10.74.3.2 10.74.1.2
host 10.74.1.4 10.74.1.2
host 10.74.1.6 10.74.1.2
host 10.74.2.2 10.74.1.3
host 10.74.3.2 10.74.1.3
host 10.74.1.4 10.74.1.3
host 10.74.1.6 10.74.1.3
