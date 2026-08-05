cat << 'EOF' > /etc/systemd/system/cloudflared.service
[Unit]
Description=Cloudflare Tunnel
After=network.online.target
Wants=network.online.target

[Service]
TimeoutStartSec=0
Type=simple
ExecStart=/usr/bin/cloudflared tunnel --config /etc/cloudflared/config.yml run zhxedHome
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now cloudflared
systemctl status cloudflared
