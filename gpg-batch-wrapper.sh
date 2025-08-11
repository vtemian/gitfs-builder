#!/bin/bash
# GPG wrapper script for non-interactive signing in CI environments
# Forces batch mode and loopback pinentry; optionally injects a passphrase

set -euo pipefail

args=("--batch" "--yes" "--no-tty" "--pinentry-mode" "loopback")

# If a passphrase is provided via env, pass it to gpg
if [[ -n "${GPG_PASSPHRASE:-}" ]]; then
  args+=("--passphrase" "${GPG_PASSPHRASE}")
fi

exec gpg "${args[@]}" "$@"
