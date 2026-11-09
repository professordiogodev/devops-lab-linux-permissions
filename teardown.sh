#!/usr/bin/env bash
# Removes everything this lab created.
set -euo pipefail
if [ "$(id -u)" -ne 0 ]; then echo "Run with sudo: sudo ./teardown.sh" >&2; exit 1; fi
rm -rf /srv/clippy
for u in deploy intern clippy; do id "$u" >/dev/null 2>&1 && userdel -r "$u" 2>/dev/null || true; done
getent group devs >/dev/null && groupdel devs || true
echo "Lab environment removed."
