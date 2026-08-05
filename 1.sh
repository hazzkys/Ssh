#!/bin/bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "[-] Jalankan sebagai root (sudo)"
    exit 1
fi

echo "[+] Install cloudflared..."
if command -v yay &>/dev/null; then
    yay -S --noconfirm cloudflared
elif command -v paru &>/dev/null; then
    paru -S --noconfirm cloudflared
else
    echo "[-] Butuh yay/paru untuk install cloudflared"
    exit 1
fi

TUNNEL_TOKEN="cfat_R2kWJnsHdCjqIKoYnpVEvA2qMAlexgU6H04DKxLmd65a188a"
read -rp "Masukkan subdomain tujuan (contoh: ssh.domainlo.com): " SUBDOMAIN

echo "[+] Menjalankan tunnel dengan token..."
# Langsung jalankan service pakai token tanpa perlu perintah create manual yang ribet
cloudflared service uninstall || true
cloudflared service install "$TUNNEL_TOKEN"
systemctl enable --now cloudflared

echo "=== SELESAI! Tunnel aktif untuk $SUBDOMAIN ==="
echo "Cek status: systemctl status cloudflared"
