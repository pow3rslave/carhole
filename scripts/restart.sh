#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

sudo systemctl restart carhole.service
sleep 1
sudo systemctl --no-pager --full status carhole.service | sed -n '1,20p' || true
