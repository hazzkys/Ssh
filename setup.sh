#!/bin/bash

# Pastikan dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo "[-] Jalankan script ini sebagai root (sudo)!"
  exit 1
fi

echo "[+] Menginstal Tailscale..."
pacman -Syu --noconfirm tailscale

echo "[+] Menyalakan daemon tailscaled..."
systemctl enable --now tailscaled

echo "[+] Menghubungkan Tailscale (Anti-Stuck Netfilter & DNS)..."
# Token dimasukkan langsung sesuai permintaan
AUTH_KEY="tskey-auth-k1ZRBStkxd11CNTRL-AY2N5yY7M6HdhQZNFcTM6H3UKihtddKw"

if [ -z "$AUTH_KEY" ] || [ "$AUTH_KEY" = "tskey-auth-k1ZRBStkxd11CNTRL-AY2N5yY7M6HdhQZNFcTM6H3UKihtddKw" ]; then
    echo "[!] Auth key belum diisi, menggunakan login interaktif..."
    tailscale up --reset --netfilter-mode=off --accept-dns=false
else
    tailscale up --authkey="$AUTH_KEY" --reset --netfilter-mode=off --accept-dns=false
fi

echo "[+] Selesai! Tailscale sudah aktif tanpa mengganggu network lokal."
