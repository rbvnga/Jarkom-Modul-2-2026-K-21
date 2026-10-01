
# PEMBAHARUAN DI SETUP_PRAB
cat <<EOF > /etc/bind/jarkom/K21.com
$TTL    604800
@       IN      SOA     prab.K21.com. root.K21.com. (
                        2026093002      ; Serial
                        604800          ; Refresh
                        86400           ; Retry
                        2419200         ; Expire
                        604800 )        ; Negative Cache TTL
;
@       IN      NS      prab.K21.com.
@       IN      NS      tedd.K21.com.
@       IN      A       10.74.3.2
prab    IN      A       10.74.1.2
tedd    IN      A       10.74.1.3
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


# di tedd, kalau mau paksa transfer ulang #
rndc retransfer K21.com
dig @10.74.1.3 penny.K21.com

named-checkconf
named-checkzone K21.com /etc/bind/jarkom/K.com
service bind9 restart


# UNTUK rndc retransfer K21.com === TEDD, JIKA PRAB ADA PERUBAHAN DI SETUP NYA
rndc retransfer K21.com