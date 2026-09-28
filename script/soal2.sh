#!/bin/bash

echo "==== Configure NAT Rootkit ===="

# Mengaktifkan interface WAN
ip link set eth0 up

# Mengaktifkan IP forwarding
sysctl -w net.ipv4.ip_forward=1

# Mengatur NAT untuk jaringan internal
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.74.0.0/16

echo "==== NAT configuration selesai ===="