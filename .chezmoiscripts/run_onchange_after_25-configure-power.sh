#!/bin/bash

set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  exit 0
fi

if ! sudo -n true 2>/dev/null; then
  echo "Administrator privileges are required to configure macOS power settings." >&2
  echo "Run 'sudo -v', then apply the chezmoi configuration again." >&2
  exit 1
fi

# Prevent system sleep while connected to external power when the display is off.
sudo pmset -c sleep 0

# Allow the Mac to wake for network access on every power source.
sudo pmset -a womp 1
