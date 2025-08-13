#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Update/upgrade
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y full-upgrade

# Packages
sudo apt-get install -y \
  python3 python3-venv python3-opencv python3-picamera2 libcamera-apps \
  python3-gunicorn python3-rpi.gpio \
  nginx apache2-utils \
  git curl htop unzip

# Ensure 'pi' can access camera
sudo usermod -aG video pi

# Nginx site (if not already deployed via your existing method)
if [[ ! -f /etc/nginx/sites-available/carhole ]]; then
  sudo tee /etc/nginx/sites-available/carhole >/dev/null <<'EOF'
server {
    listen 80;
    server_name _;
    location / {
        auth_basic "Restricted";
        auth_basic_user_file /etc/nginx/.htpasswd;
        proxy_pass http://127.0.0.1:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    location /video_feed {
        auth_basic "Restricted";
        auth_basic_user_file /etc/nginx/.htpasswd;
        proxy_pass http://127.0.0.1:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_buffering off;
    }
}
EOF
  sudo ln -sf /etc/nginx/sites-available/carhole /etc/nginx/sites-enabled/carhole
  sudo nginx -t && sudo systemctl reload nginx
fi

echo "Bootstrap complete. Create htpasswd if needed:"
echo "  sudo htpasswd -c /etc/nginx/.htpasswd <user>"
