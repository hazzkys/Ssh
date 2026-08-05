#!/bin/bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "[-] Jalankan sebagai root (sudo)"
    exit 1
fi

echo "[+] Install cloudflared..."
yay -S --noconfirm cloudflared || paru -S --noconfirm cloudflared

read -rp "Masukkan nama tunnel (contoh: homeserver-ssh): " TUNNEL_NAME
read -rp "Masukkan subdomain tujuan (contoh: ssh.domainlo.com): " SUBDOMAIN

echo "[+] Silakan login ke Cloudflare..."
cloudflared tunnel login

echo "[+] Membuat tunnel..."
cloudflared tunnel create "$TUNNEL_NAME" || true

TUNNEL_ID=$(cloudflared tunnel list | grep "^$TUNNEL_NAME " | awk '{print $1}')

mkdir -p /etc/cloudflared
cat > /etc/cloudflared/config.yml << EOF
tunnel: $TUNNEL_ID
credentials-file: /root/.cloudflared/$TUNNEL_ID.json

ingress:
  - hostname: $SUBDOMAIN
    service: ssh://localhost:22
  - service: http_status:404
EOF

echo "[+] Setup DNS route..."
cloudflared tunnel route dns "$TUNNEL_NAME" "$SUBDOMAIN"

echo "[+] Install systemd service..."
cloudflared service install
systemctl enable --now cloudflared

echo "=== SELESAI! Tunnel aktif untuk $SUBDOMAIN ==="
