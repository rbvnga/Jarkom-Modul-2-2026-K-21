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



curl -u prabs:'pakar_pinter_jadi_gob***' -I http://www.K21.com/admin     # 200 ???
curl http://www.K21.com/eternal/           # PHP dirender
curl http://static.K21.com/orion/          # statis
curl http://vault.K21.com/arsip/           # autoindex
curl http://core.K21.com/profil            # URL bersih