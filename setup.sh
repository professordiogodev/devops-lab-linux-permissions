#!/usr/bin/env bash
# Builds the "leaky" staging server under /srv/clipstr. Safe to run again: it resets the scene.
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this with sudo:  sudo ./setup.sh" >&2
  exit 1
fi

BASE=/srv/clipstr

getent group devs   >/dev/null || groupadd devs
id clipstr >/dev/null 2>&1 || useradd --system --no-create-home --shell /usr/sbin/nologin clipstr
id deploy  >/dev/null 2>&1 || useradd --create-home --shell /bin/bash deploy
id intern  >/dev/null 2>&1 || useradd --create-home --shell /bin/bash intern
usermod -aG devs deploy        # deploy is a developer; intern and clipstr are not

rm -rf "$BASE"
mkdir -p "$BASE"/{app/releases/v1,config,logs,scripts,keys,data,backups}

cat > "$BASE/app/releases/v1/main.py" <<'PY'
# Clipstr release v1 (stand-in for the real app)
print("clipstr v1 is running")
PY

cat > "$BASE/config/app.env" <<'ENV'
DATABASE_URL=postgresql://clipstr:Tr0ub4dor-staging@db.internal:5432/clipstr
STRIPE_API_KEY=sk_test_FAKE_not_a_real_key_0000
SECRET_KEY=staging-only-do-not-reuse
ENV

cat > "$BASE/scripts/deploy.sh" <<'SH'
#!/usr/bin/env bash
echo "deploying clipstr..."
SH

# A fake "private key" (not a real key, just text that looks like one)
printf -- '-----BEGIN OPENSSH PRIVATE KEY-----\nFAKE-KEY-FOR-THE-LAB-NOT-A-REAL-KEY\n-----END OPENSSH PRIVATE KEY-----\n' > "$BASE/keys/deploy_key"

# Old log lines, and a harmless binary that someone marked setuid "to make it work"
echo "2026-11-02 09:14:01 INFO clipstr started" > "$BASE/logs/app.log"
cp /usr/bin/true "$BASE/backups/dump"

# ---------------------------------------------------------------------------
# Apply the BAD state. This is what the scan found. (Do not read the lab
# solution here: the point is to find these yourself.)
# ---------------------------------------------------------------------------
chown -R intern:intern "$BASE"            # "the intern set it all up"
chmod -R 755 "$BASE"
chmod 666 "$BASE/config/app.env"
chmod 666 "$BASE/app/releases/v1/main.py"
chmod 644 "$BASE/scripts/deploy.sh"
chmod 644 "$BASE/keys/deploy_key"
chmod 700 "$BASE/app/releases"           # deploy cannot even walk into releases/
chown root:root "$BASE/logs" "$BASE/data"
chmod 777 "$BASE/logs"
chmod 755 "$BASE/data"
chown root:root "$BASE/backups/dump"
chmod 4755 "$BASE/backups/dump"

cat > "$BASE/deploy-error.log" <<'LOG'
2026-11-07 17:52:08 deploy: starting release v1
2026-11-07 17:52:08 deploy: cat /srv/clipstr/app/releases/v1/main.py
cat: /srv/clipstr/app/releases/v1/main.py: Permission denied
2026-11-07 17:52:08 deploy: FAILED (exit 1)
LOG
chown intern:intern "$BASE/deploy-error.log"

echo
echo "Scene ready. The staging server is at $BASE"
echo "Users: clipstr (the app), deploy (a developer, in group devs), intern (not in devs)."
echo "The security scan says: 'intern can read the production-style secrets'. Go and look."
