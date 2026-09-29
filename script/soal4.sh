# PRAB (DNS MASTER)
apt update
apt install bind9 -y
ln -s /etc/init.d/named /etc/init.d/bind9

cat <<EOF > /etc/bind/named.conf.local
zone "K21.com" {
    type master;
    file "/etc/bind/jarkom/K21.com";
    notify yes;
    allow-transfer { 10.74.1.3; };
    also-notify { 10.74.1.3; };
};
EOF

cat <<EOF > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    forwarders {
        192.168.122.1;
    };
    allow-query { any; };
    auth-nxdomain no;
    dnssec-validation no;
    listen-on-v6 { any; };
};
EOF

# Membuat Zona
mkdir -p /etc/bind/jarkom

cat <<EOF > /etc/bind/jarkom/K21.com
$TTL    604800
@       IN      SOA     prab.K21.com. root.K21.com. (
                        2026092801      ; Serial
                        604800          ; Refresh
                        86400           ; Retry
                        2419200         ; Expire
                        604800 )        ; Negative Cache TTL
;
@       IN      NS      prab.K21.com.
@       IN      NS      tedd.K21.com.
prab    IN      A       10.74.1.2
tedd    IN      A       10.74.1.3
@       IN      A       10.74.3.2
EOF

named-checkconf
named-checkzone K21.com /etc/bind/jarkom/K.com
service bind9 restart


# TEDD (DNS SLAVE)
apt update
apt install bind9 -y
ln -s /etc/init.d/named /etc/init.d/bind9

cat <<EOF > /etc/bind/named.conf.local
zone "K21.com" {
    type slave;
    masters { 10.74.1.2; };
    file "/var/lib/bind/K21.com";
};
EOF

cat <<EOF > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    forwarders {
        192.168.122.1;
    };
    allow-query { any; };
    auth-nxdomain no;
    dnssec-validation no;
    listen-on-v6 { any; };
};
EOF

service bind9 restart


# SEMUA HOST NON ROUTER 
cat <<EOF > /root/.bashrc
echo "nameserver 10.74.1.2" > /etc/resolv.conf
echo "nameserver 10.74.1.3" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf
EOF

# PRAB
cat <<EOF > /root/.bashrc
echo "nameserver 10.74.1.2" > /etc/resolv.conf
echo "nameserver 10.74.1.3" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf
chmod +x /root/setup_prab.sh
./setup_prab.sh
EOF

# TEDD
cat <<EOF > /root/.bashrc
echo "nameserver 10.74.1.2" > /etc/resolv.conf
echo "nameserver 10.74.1.3" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf
chmod +x /root/setup_tedd.sh
./setup_tedd.sh
EOF


