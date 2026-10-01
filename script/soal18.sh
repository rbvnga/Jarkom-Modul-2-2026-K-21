# PRAB
grep -n "abbey\|Serial" /root/setup_prab.sh

#Kalau serial 2026093013 dan abbey 203.0.113.18:
sed -i 's/^abbey   15      IN      A       203.0.113.18/abbey   15      IN      A       10.74.2.2/' /root/setup_prab.sh
sed -i 's/2026093013      ; Serial/2026093014      ; Serial/' /root/setup_prab.sh
bash /root/setup_prab.sh

# TEDD
dig @10.74.1.3 K21.com SOA +short
dig @10.74.1.3 abbey.K21.com +noall +answer

# PRAB 
date; sed -i 's/^abbey   15      IN      A       10.74.2.2/abbey   15      IN      A       203.0.113.18/' /root/setup_prab.sh; sed -i 's/2026093014      ; Serial/2026093015      ; Serial/' /root/setup_prab.sh; bash /root/setup_prab.sh; dig @10.74.1.2 abbey.K21.com +noall +answer


# ALPHA
service dnsmasq restart; sleep 2; clear; for i in $(seq 1 40); do date +%T; dig @127.0.0.1 -p 5353 abbey.K21.com +noall +answer +comments | grep -E "flags|abbey"; sleep 2; done


# CEK TEDD
dig @10.74.1.3 K21.com SOA +short
dig @10.74.1.3 abbey.K21.com +noall +answer

# KEMBALIKAN PRAB
sed -i 's/^abbey   15      IN      A       203.0.113.18/abbey   IN      A       10.74.2.2/' /root/setup_prab.sh
sed -i 's/2026093015      ; Serial/2026093016      ; Serial/' /root/setup_prab.sh
bash /root/setup_prab.sh