#!/bin/bash

# 1. Dapatkan nama node saat ini (atau dari argumen jika ada)
NODE_NAME="${1:-$(hostname)}"

# Pastikan hostname diset sesuai node
hostnamectl set-hostname "$NODE_NAME" 2>/dev/null || echo "$NODE_NAME" > /etc/hostname
hostname "$NODE_NAME"

# 2. Set konfigurasi DNS Client (/etc/resolv.conf)
cat <<RESOLV > /etc/resolv.conf
nameserver 10.74.1.2
nameserver 10.74.1.3
nameserver 192.168.122.1
RESOLV

# 3. Konfigurasi khusus untuk Server BIND9 (prab / tedd)
if [ "$NODE_NAME" = "prab" ] || [ "$NODE_NAME" = "tedd" ]; then
    echo "Configuring BIND9 for $NODE_NAME..."
    
    # Buat direktori zone jika belum ada
    mkdir -p /etc/bind/jarkom

    if [ "$NODE_NAME" = "prab" ]; then
        # Konfigurasi named.conf.local Master
        cat << 'EOF' > /etc/bind/named.conf.local
zone "K21.com" {
    type master;
    file "/etc/bind/jarkom/K21.com";
    notify yes;
    allow-transfer { 10.74.1.3; };
    also-notify { 10.74.1.3; };
};
EOF

        # Buat Zone File Master
        cat << 'EOF' > /etc/bind/jarkom/K21.com
$TTL    604800
@       IN      SOA     prab.K21.com. root.K21.com. (
                        2026092902      ; Serial
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
EOF

    elif [ "$NODE_NAME" = "tedd" ]; then
        # Konfigurasi named.conf.local Slave
        cat << 'EOF' > /etc/bind/named.conf.local
zone "K21.com" {
    type slave;
    file "/var/cache/bind/db.K21.com";
    masters { 10.74.1.2; };
};
EOF
    fi

    # Restart service BIND9
    service bind9 restart 2>/dev/null || systemctl restart bind9
fi

echo "Setup completed successfully for node: $NODE_NAME"
