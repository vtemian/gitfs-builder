#!/bin/bash
# GPG wrapper script for non-interactive signing in CI environments
# This script forces batch mode and prevents TTY access attempts

# Always add batch mode and loopback pinentry
exec gpg --batch --yes --pinentry-mode loopback "$@"