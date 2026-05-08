#!/usr/bin/env bash
# Removes the WiFi watchdog timer, service, and script.
set -euo pipefail

green='\033[0;32m'; red='\033[0;31m'; nc='\033[0m'
info()  { printf "${green}[INFO]${nc}  %s\n" "$*"; }
error() { printf "${red}[ERROR]${nc} %s\n" "$*" >&2; }

[[ $EUID -eq 0 ]] || { error "Run with sudo: sudo ./uninstall.sh"; exit 1; }

info "Disabling wifi-watchdog.timer..."
systemctl disable --now wifi-watchdog.timer 2>/dev/null || true
systemctl stop wifi-watchdog.service 2>/dev/null || true

info "Removing systemd units..."
rm -f /etc/systemd/system/wifi-watchdog.timer
rm -f /etc/systemd/system/wifi-watchdog.service
systemctl daemon-reload
systemctl reset-failed wifi-watchdog.service 2>/dev/null || true

info "Removing wifi-watchdog.sh..."
rm -f /usr/local/bin/wifi-watchdog.sh

info "Done."
