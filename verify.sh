#!/usr/bin/env bash
# Checks the end state of /srv/clipstr. Run with: sudo ./verify.sh | tee evidence/verify.txt
set -uo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this with sudo:  sudo ./verify.sh" >&2
  exit 1
fi

B=/srv/clipstr
pass=0; failn=0

check() {   # check "description" command...
  local d="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "PASS  $d"; pass=$((pass+1)); else echo "FAIL  $d"; failn=$((failn+1)); fi
}
as() { local u="$1"; shift; sudo -u "$u" "$@"; }
mode_is() { [ "$(stat -c '%U:%G %a' "$1")" = "$2" ]; }

echo "== Secrets =="
check "intern can NOT read config/app.env"            bash -c "! sudo -u intern test -r $B/config/app.env"
check "clipstr (the app) CAN read config/app.env"     as clipstr test -r "$B/config/app.env"
check "config/app.env is root:clipstr with mode 640"  mode_is "$B/config/app.env" "root:clipstr 640"
check "config/ can be entered by clipstr only (750 root:clipstr)" mode_is "$B/config" "root:clipstr 750"

echo "== Logs =="
check "logs/ is clipstr:devs with SGID (2775)"        mode_is "$B/logs" "clipstr:devs 2775"
check "a file clipstr creates in logs/ gets group devs" bash -c "sudo -u clipstr touch $B/logs/.verify && [ \"\$(stat -c %G $B/logs/.verify)\" = devs ]; r=\$?; rm -f $B/logs/.verify; exit \$r"
check "deploy (in devs) can read the logs"            as deploy test -r "$B/logs"
check "intern can NOT write to logs/"                 bash -c "! sudo -u intern test -w $B/logs"

echo "== Deployment =="
check "deploy can walk into app/releases/ and list v1" as deploy ls "$B/app/releases/v1"
check "deploy can execute scripts/deploy.sh"          as deploy test -x "$B/scripts/deploy.sh"
check "nobody but root can modify scripts/deploy.sh"  bash -c "! sudo -u intern test -w $B/scripts/deploy.sh && ! sudo -u deploy test -w $B/scripts/deploy.sh && ! sudo -u clipstr test -w $B/scripts/deploy.sh"
check "clipstr can read main.py but NOT modify it"    bash -c "sudo -u clipstr test -r $B/app/releases/v1/main.py && ! sudo -u clipstr test -w $B/app/releases/v1/main.py"

echo "== Keys =="
check "keys/deploy_key is deploy:deploy with mode 600" mode_is "$B/keys/deploy_key" "deploy:deploy 600"
check "intern can NOT read the private key"           bash -c "! sudo -u intern test -r $B/keys/deploy_key"

echo "== Data and backups =="
check "clipstr can write to data/"                    as clipstr test -w "$B/data"
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
