# wifi-watchdog

A small systemd-based watchdog that keeps a Raspberry Pi Zero 2 W online over WiFi by bouncing `wlan0` whenever the default gateway becomes unreachable.

## Why this exists

The Pi Zero 2 W in question has no Ethernet, sits at roughly **-62 dBm** signal, and connects through a router with **band steering** enabled. The combination causes the Pi to occasionally lose its WiFi association and never recover on its own — leaving the device unreachable until someone power-cycles it.

This watchdog runs every minute, pings the default gateway through `wlan0`, and if the pings fail it brings the interface down and back up. That's enough to force a fresh association and get the Pi back on the network without a reboot.

## How it works

- [wifi-watchdog.sh](wifi-watchdog.sh) — pings the gateway 3 times via `wlan0` with a 5s timeout per ping. On failure, runs `ip link set wlan0 down`, sleeps 3s, and brings it back up.
- [wifi-watchdog.service](wifi-watchdog.service) — oneshot systemd unit that invokes the script.
- [wifi-watchdog.timer](wifi-watchdog.timer) — fires the service 1 minute after boot and every minute thereafter.

## Install

On the Pi:

```sh
git clone <this repo>
cd wifi-watchdog
sudo ./install.sh
```

The installer copies the script to `/usr/local/bin/`, drops the systemd units into `/etc/systemd/system/`, and enables the timer.

## Verify

```sh
systemctl status wifi-watchdog.timer
systemctl list-timers wifi-watchdog.timer
journalctl -u wifi-watchdog.service
```

The journal will be quiet on healthy runs and only log when a restart is triggered.

## Tuning

Edit `/usr/local/bin/wifi-watchdog.sh` if you want to change:

- `IFACE` — the wireless interface (default `wlan0`)
- `PING_COUNT` / `PING_TIMEOUT` — how aggressive the health check is

Edit `/etc/systemd/system/wifi-watchdog.timer` and run `sudo systemctl daemon-reload && sudo systemctl restart wifi-watchdog.timer` to change the check interval.
