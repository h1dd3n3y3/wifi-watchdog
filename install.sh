#!/usr/bin/env bash
# Installs the WiFi watchdog as a systemd timer that runs every minute.
# Pings the default gateway via wlan0 and bounces the interface if unreachable.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

green='\033[0;32m'; red='\033[0;31m'; nc='\033[0m'
info()  { printf "${green}[INFO]${nc}  %s\n" "$*"; }
error() { printf "${red}[ERROR]${nc} %s\n" "$*" >&2; }

[[ $EUID -eq 0 ]] || { error "Run with sudo: sudo ./install-wifi-watchdog.sh"; exit 1; }

info "Installing wifi-watchdog.sh..."
cp "$SCRIPT_DIR/wifi-watchdog.sh" /usr/local/bin/wifi-watchdog.sh
chmod +x /usr/local/bin/wifi-watchdog.sh

info "Installing systemd units..."
cp "$SCRIPT_DIR/wifi-watchdog.service" /etc/systemd/system/wifi-watchdog.service
cp "$SCRIPT_DIR/wifi-watchdog.timer" /etc/systemd/system/wifi-watchdog.timer
systemctl daemon-reload

info "Enabling wifi-watchdog.timer..."
systemctl enable --now wifi-watchdog.timer

info "Done. Check status with: systemctl status wifi-watchdog.timer"
