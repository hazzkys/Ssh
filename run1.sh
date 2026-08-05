#!/bin/bash
set -euo pipefail

# Pastikan dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
    echo "[-] Jalankan skrip ini sebagai root (sudo)"
    exit 1
fi

DOMAIN="home.server.com.vpsyantomin12.dpdns.org"

echo "[+] Membuat skrip konfigurasi SSH client..."
# Menulis konfigurasi SSH agar otomatis menggunakan cloudflared access proxy
mkdir -p ~/.ssh

cat > ~/.ssh/config << EOF
Host $DOMAIN
    ProxyCommand /usr/local/bin/cloudflared access ssh --hostname %h
    User zhxed
EOF

chmod 600 ~/.ssh/config

echo "=== SELESAI! ==="
echo "Sekarang kamu bisa langsung meremote server cukup dengan mengetik:"
echo "ssh $DOMAIN"
