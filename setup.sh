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
# Masukkan auth key lu di bawah ini atau biarkan kosong jika ingin login manual
AUTH_KEY="KASIH_AUTH_KEY_LU_DISINI"

if [ -z "$AUTH_KEY" ] || [ "$AUTH_KEY" = "KASIH_AUTH_KEY_LU_DISINI" ]; then
    echo "[!] Auth key belum diisi, menggunakan login interaktif..."
    tailscale up --reset --netfilter-mode=off --accept-dns=false
else
    tailscale up --authkey="$AUTH_KEY" --reset --netfilter-mode=off --accept-dns=false
fi

echo "[+] Selesai! Tailscale sudah aktif tanpa mengganggu network lokal."
