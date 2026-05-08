#!/usr/bin/env bash
# Pulls the latest version from git and reinstalls the WiFi watchdog.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

green='\033[0;32m'; red='\033[0;31m'; nc='\033[0m'
info()  { printf "${green}[INFO]${nc}  %s\n" "$*"; }
error() { printf "${red}[ERROR]${nc} %s\n" "$*" >&2; }

[[ $EUID -eq 0 ]] || { error "Run with sudo: sudo ./update.sh"; exit 1; }

if [[ -d "$SCRIPT_DIR/.git" ]]; then
    info "Pulling latest changes..."
    git -C "$SCRIPT_DIR" pull --ff-only
else
    info "Not a git checkout — skipping pull, reinstalling from local files."
fi

info "Reinstalling wifi-watchdog.sh..."
cp "$SCRIPT_DIR/wifi-watchdog.sh" /usr/local/bin/wifi-watchdog.sh
chmod +x /usr/local/bin/wifi-watchdog.sh

info "Reinstalling systemd units..."
cp "$SCRIPT_DIR/wifi-watchdog.service" /etc/systemd/system/wifi-watchdog.service
cp "$SCRIPT_DIR/wifi-watchdog.timer" /etc/systemd/system/wifi-watchdog.timer
systemctl daemon-reload

info "Restarting wifi-watchdog.timer..."
systemctl enable --now wifi-watchdog.timer
systemctl restart wifi-watchdog.timer

info "Done. Check status with: systemctl status wifi-watchdog.timer"
