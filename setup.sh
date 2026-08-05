#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "[-] Jalankan script ini sebagai root (sudo)!"
  exit 1
fi

echo "[+] Menginstal Tailscale..."
pacman -Syu --noconfirm tailscale

echo "[+] Menyalakan daemon tailscaled..."
systemctl enable --now tailscaled

echo "[+] Menghubungkan Tailscale..."
sudo tailscale up --authkey=tskey-auth-k1ZRBStkxd11CNTRL-AY2N5yY7M6HdhQZNFcTM6H3UKihtddKw --reset --netfilter-mode=off --accept-dns=false

echo "[+] Selesai!"
