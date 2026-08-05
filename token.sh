#!/bin/bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "[-] Jalankan sebagai root (sudo)"
    exit 1
fi

echo "[+] Install cloudflared (via AUR helper)..."
if command -v yay &>/dev/null; then
    yay -S --noconfirm cloudflared
elif command -v paru &>/dev/null; then
    paru -S --noconfirm cloudflared
else
    echo "[-] Butuh yay/paru untuk install cloudflared dari AUR"
    exit 1
fi

# Token lo sudah otomatis terpasang di sini
TUNNEL_TOKEN="cfat_R2kWJnsHdCjqIKoYnpVEvA2qMAlexgU6H04DKxLmd65a188a"

read -rp "Masukkan nama tunnel (contoh: homeserver-ssh): " TUNNEL_NAME

echo "[+] Membuat tunnel..."
cloudflared tunnel create "$TUNNEL_NAME" || true

TUNNEL_ID=$(cloudflared tunnel list | grep "^$TUNNEL_NAME " | awk '{print $1}')
if [ -z "$TUNNEL_ID" ]; then
    echo "[-] Gagal dapat Tunnel ID"
    exit 1
fi
echo "[*] Tunnel ID: $TUNNEL_ID"

read -rp "Masukkan subdomain (contoh: ssh.domainlo.com): " SUBDOMAIN

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
cloudflared service install --config /etc/cloudflared/config.yml
systemctl enable --now cloudflared

echo "=== SELESAI! Tunnel aktif untuk $SUBDOMAIN ==="
echo "Cek status: systemctl status cloudflared"
echo "Logs: journalctl -u cloudflared -f"
