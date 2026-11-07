#!/usr/bin/env bash
# Friday 17:55. Someone "fixes" a Permission denied the quick way.
set -euo pipefail
if [ "$(id -u)" -ne 0 ]; then echo "Run with sudo: sudo ./panic.sh" >&2; exit 1; fi
echo "Running the infamous quick fix: chmod -R 777 /srv/clipstr"
chmod -R 777 /srv/clipstr
echo "Done. The deploy works now. What could possibly go wrong?"
