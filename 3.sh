#!/bin/bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "[-] Jalankan sebagai root (sudo)"
    exit 1
fi

TUNNEL_NAME="zhxedHome"
SUBDOMAIN="home.server.com.vpsyantomin12.dpdns.org"
TUNNEL_ID="63b8bf1c-0ba0-44ab-a95c-9afc205f8864"

echo "[+] Membuat direktori konfigurasi..."
mkdir -p /etc/cloudflared
mkdir -p /root/.cloudflared

echo "[+] Menulis file konfigurasi config.yml..."
cat > /etc/cloudflared/config.yml << EOF
tunnel: $TUNNEL_ID
credentials-file: /root/.cloudflared/$TUNNEL_ID.json

ingress:
  - hostname: $SUBDOMAIN
    service: ssh://localhost:22
  - service: http_status:404
EOF

echo "[+] Install systemd service..."
# Hapus flag --config karena cloudflared otomatis mendeteksi config di /etc/cloudflared/
cloudflared service install

echo "[+] Mengaktifkan service cloudflared..."
systemctl enable --now cloudflared

echo "=== SELESAI! Tunnel aktif untuk $SUBDOMAIN ==="
echo "Cek status: systemctl status cloudflared"
