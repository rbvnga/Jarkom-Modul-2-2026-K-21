# PRAB
#!/bin/bash
set -e

if ! dpkg -l | grep -qw "^ii  bind9 "; then
    apt -o Acquire::Check-Valid-Until=false update
    apt install -y bind9 dnsutils
fi

if [ ! -e /etc/init.d/bind9 ]; then
    ln -s /etc/init.d/named /etc/init.d/bind9
fi

mkdir -p /etc/bind/jarkom

if [ ! -f /etc/bind/named.conf.local ] || ! grep -q "zone \"K21.com\"" /etc/bind/named.conf.local; then
cat > /etc/bind/named.conf.local << 'EOF'
zone "K21.com" {
    type master;
    file "/etc/bind/jarkom/K21.com";
    notify yes;
    allow-transfer { 10.74.1.3; };
    also-notify { 10.74.1.3; };
};
EOF
fi

# Selalu ditulis ulang agar recursion pasti aktif
cat > /etc/bind/named.conf.options << 'EOF'
options {
    directory "/var/cache/bind";
    forwarders {
        192.168.122.1;
    };
    forward only;
    recursion yes;
    allow-recursion { any; };
    allow-query { any; };
    auth-nxdomain no;
    dnssec-validation no;
    listen-on-v6 { any; };
};
EOF

cat > /etc/bind/jarkom/K21.com << 'EOF'
$TTL    604800
@       IN      SOA     prab.K21.com. root.K21.com. (
                        2026100101      ; Serial
                        604800          ; Refresh
                        86400           ; Retry
                        2419200         ; Expire
                        604800 )        ; Negative Cache TTL
;
@       IN      NS      prab.K21.com.
@       IN      NS      tedd.K21.com.
@       IN      A       10.74.3.2

; DNS Server Record (Soal 4)
prab    IN      A       10.74.1.2
tedd    IN      A       10.74.1.3

; Node Domain Mapping (Soal 5)
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

; Area Grouping (Soal 7)
vault   IN      A       10.74.1.4
vault   IN      A       10.74.1.5
core    IN      A       10.74.1.6
core    IN      A       10.74.1.7
www     IN      CNAME   penny.K21.com.
static  IN      CNAME   abbey.K21.com.

; TXT Record Klien (Soal 17)
alpha   IN      TXT     "alpha"
beta    IN      TXT     "beta"
gamma   IN      TXT     "gamma"
delta   IN      TXT     "delta"
epsilon IN      TXT     "epsilon"

; Outbound CNAME (Soal 19)
outbound IN     CNAME   http.badssl.com.
EOF

named-checkconf
named-checkzone K21.com /etc/bind/jarkom/K21.com
service bind9 restart

# TEDD

#!/bin/bash
set -e

if ! dpkg -l | grep -qw "^ii  bind9 "; then
    apt -o Acquire::Check-Valid-Until=false update
    apt install -y bind9 dnsutils
fi

if [ ! -e /etc/init.d/bind9 ]; then
    ln -s /etc/init.d/named /etc/init.d/bind9
fi

if [ ! -f /etc/bind/named.conf.local ] || ! grep -q "zone \"K21.com\"" /etc/bind/named.conf.local; then
cat > /etc/bind/named.conf.local << 'EOF'
zone "K21.com" {
    type slave;
    masters { 10.74.1.2; };
    file "/var/lib/bind/K21.com";
};
EOF
fi

# Selalu ditulis ulang agar recursion pasti aktif
cat > /etc/bind/named.conf.options << 'EOF'
options {
    directory "/var/cache/bind";
    forwarders {
        192.168.122.1;
    };
    forward only;
    recursion yes;
    allow-recursion { any; };
    allow-query { any; };
    auth-nxdomain no;
    dnssec-validation no;
    listen-on-v6 { any; };
};
EOF

named-checkconf
service bind9 restart


# PRAB
dig @10.74.1.3 K21.com SOA +short
dig @10.74.1.2 K21.com SOA +short

# alpha
dig outbound.K21.com
curl http://outbound.K21.com