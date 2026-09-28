# Prab (DNS Master) dan Tedd (DNS Slave)
apt update
apt install bind9 -y
ln -s /etc/init.d/named /etc/init.d/bind9