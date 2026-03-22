#!/bin/bash
set -euo pipefail

SUPERVISORD_CONFIG="${OPENCLAW_SUPERVISORD_CONFIG:-/home/openclaw/.config/supervisor/supervisord.conf}"

# Copy GPG keys from mounted volume to native filesystem
if [ -d /home/openclaw/.gnupg ] && [ -f /home/openclaw/.gnupg/pubring.kbx ]; then
  mkdir -p /opt/gnupg && chmod 700 /opt/gnupg
  cp -r /home/openclaw/.gnupg/* /opt/gnupg/ 2>/dev/null
  chmod 700 /opt/gnupg
  chmod 600 /opt/gnupg/*.kbx /opt/gnupg/trustdb.gpg 2>/dev/null
  chmod 700 /opt/gnupg/private-keys-v1.d 2>/dev/null
  chmod 600 /opt/gnupg/private-keys-v1.d/* 2>/dev/null
fi

if [ -f "$SUPERVISORD_CONFIG" ]; then
  echo "[entrypoint] starting supervisord with $SUPERVISORD_CONFIG"
  exec /usr/bin/supervisord -n -c "$SUPERVISORD_CONFIG"
fi

exec "$@"
