#!/usr/bin/env bash
set -euo pipefail
sudo cp -f /home/pi/carhole/systemd/carhole.service /etc/systemd/system/carhole.service
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable carhole.service
sudo systemctl restart carhole.service
sudo systemctl status carhole.service --no-pager
