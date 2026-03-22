#!/bin/bash
set -euo pipefail

SUPERVISORD_CONFIG="/etc/supervisor/supervisord.conf"
DEFAULT_CMD=(openclaw gateway --allow-unconfigured --bind lan)

# Copy GPG keys from mounted volume to native filesystem
if [ -d /home/openclaw/.gnupg ] && [ -f /home/openclaw/.gnupg/pubring.kbx ]; then
  mkdir -p /opt/gnupg && chmod 700 /opt/gnupg
  cp -r /home/openclaw/.gnupg/* /opt/gnupg/ 2>/dev/null
  chmod 700 /opt/gnupg
  chmod 600 /opt/gnupg/*.kbx /opt/gnupg/trustdb.gpg 2>/dev/null
  chmod 700 /opt/gnupg/private-keys-v1.d 2>/dev/null
  chmod 600 /opt/gnupg/private-keys-v1.d/* 2>/dev/null
fi

mkdir -p /home/openclaw/.config/supervisor/conf.d

if [ "$#" -eq 0 ]; then
  set -- "${DEFAULT_CMD[@]}"
fi

if [ "$*" = "${DEFAULT_CMD[*]}" ]; then
  echo "[entrypoint] starting supervisord with $SUPERVISORD_CONFIG"
  exec /usr/bin/supervisord -n -c "$SUPERVISORD_CONFIG"
fi

exec "$@"
