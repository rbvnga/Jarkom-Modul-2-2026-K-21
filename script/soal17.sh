# update setup_prab.sh


# 1. Update Zone File K21.com
cat << 'EOF' > /etc/bind/jarkom/K21.com
$TTL    604800
@       IN      SOA     prab.K21.com. root.K21.com. (
                        202609290      ; Serial SOA
                        604800          ; Refre4sh
                        86400           ; Retry
                        2419200         ; Expire
                        604800 )        ; Negative Cache TTL
;
@       IN      NS      prab.K21.com.
@       IN      NS      tedd.K21.com.

; Base Records
prab    IN      A       10.74.1.2
tedd    IN      A       10.74.1.3
@       IN      A       10.74.3.2

; Client Records
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

; Soal No. 7: Web Statis (vault) & Web Dinamis (core)
vault   IN      A       10.74.1.4
vault   IN      A       10.74.1.5
core    IN      A       10.74.1.6
core    IN      A       10.74.1.7

; Soal No. 7: Alias (CNAME)
www     IN      CNAME   penny.K21.com.
static  IN      CNAME   abbey.K21.com.

; TXT Record Klien (Soal 17)
alpha   IN      TXT     "alpha"
beta    IN      TXT     "beta"
gamma   IN      TXT     "gamma"
delta   IN      TXT     "delta"
epsilon IN      TXT     "epsilon"
EOF

# 2. Cek sintaks zone file & restart BIND9
named-checkzone K21.com /etc/bind/jarkom/K21.com
service bind9 restart
