#!/usr/bin/env bash
# Checks the end state of /srv/clippy. Run with: sudo ./verify.sh | tee evidence/verify.txt
set -uo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this with sudo:  sudo ./verify.sh" >&2
  exit 1
fi

B=/srv/clippy
pass=0; failn=0

check() {   # check "description" command...
  local d="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "PASS  $d"; pass=$((pass+1)); else echo "FAIL  $d"; failn=$((failn+1)); fi
}
as() { local u="$1"; shift; sudo -u "$u" "$@"; }
mode_is() { [ "$(stat -c '%U:%G %a' "$1")" = "$2" ]; }

echo "== Secrets =="
check "intern can NOT read config/app.env"            bash -c "! sudo -u intern test -r $B/config/app.env"
check "clippy (the app) CAN read config/app.env"     as clippy test -r "$B/config/app.env"
check "config/app.env is root:clippy with mode 640"  mode_is "$B/config/app.env" "root:clippy 640"
check "config/ can be entered by clippy only (750 root:clippy)" mode_is "$B/config" "root:clippy 750"

echo "== Logs =="
check "logs/ is clippy:devs with SGID (2775)"        mode_is "$B/logs" "clippy:devs 2775"
check "a file clippy creates in logs/ gets group devs" bash -c "sudo -u clippy touch $B/logs/.verify && [ \"\$(stat -c %G $B/logs/.verify)\" = devs ]; r=\$?; rm -f $B/logs/.verify; exit \$r"
check "deploy (in devs) can read the logs"            as deploy test -r "$B/logs"
check "intern can NOT write to logs/"                 bash -c "! sudo -u intern test -w $B/logs"

echo "== Deployment =="
check "deploy can walk into app/releases/ and list v1" as deploy ls "$B/app/releases/v1"
check "deploy can execute scripts/deploy.sh"          as deploy test -x "$B/scripts/deploy.sh"
check "nobody but root can modify scripts/deploy.sh"  bash -c "! sudo -u intern test -w $B/scripts/deploy.sh && ! sudo -u deploy test -w $B/scripts/deploy.sh && ! sudo -u clippy test -w $B/scripts/deploy.sh"
check "clippy can read main.py but NOT modify it"    bash -c "sudo -u clippy test -r $B/app/releases/v1/main.py && ! sudo -u clippy test -w $B/app/releases/v1/main.py"

echo "== Keys =="
check "keys/deploy_key is deploy:deploy with mode 600" mode_is "$B/keys/deploy_key" "deploy:deploy 600"
check "intern can NOT read the private key"           bash -c "! sudo -u intern test -r $B/keys/deploy_key"

echo "== Data and backups =="
check "clippy can write to data/"                    as clippy test -w "$B/data"
check "intern can NOT read data/"                     bash -c "! sudo -u intern test -r $B/data"

echo "== Whole tree =="
check "no world-writable files or directories"        bash -c "[ -z \"\$(find $B -perm -o+w ! -type l)\" ]"
check "no setuid or setgid files"                     bash -c "[ -z \"\$(find $B -type f -perm /6000)\" ]"

echo
if [ "$failn" -eq 0 ]; then
  echo "ALL CHECKS PASSED ($pass/$pass)"
  exit 0
else
  echo "$failn CHECK(S) FAILED ($pass passed)"
  exit 1
fi
