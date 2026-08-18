#!/bin/bash

set -euo pipefail

# ── Configuration ────────────────────────────────────────────────

export OP_ACCOUNT="${OP_ACCOUNT:-my.1password.com}"
readonly OP_ACCOUNT

readonly DOTFILES_REPO="git@github.com:glenflorendo/dotcentral.git"

# ── Platform checks ──────────────────────────────────────────────

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This bootstrap script currently supports macOS only." >&2
  exit 1
fi

if [[ "$(uname -m)" != "arm64" ]]; then
  echo "This bootstrap script currently supports Apple Silicon Macs only." >&2
  exit 1
fi

# ── Administrator privileges ────────────────────────────────────

echo "Administrator privileges are required to configure this Mac."

if ! sudo -v; then
  echo "Unable to obtain administrator privileges." >&2
  exit 1
fi

# Refresh the sudo timestamp until this bootstrap process exits.
(
  while kill -0 "$$" 2>/dev/null; do
    sudo -n true
    sleep 60
  done
) &
SUDO_KEEPALIVE_PID=$!

cleanup() {
  kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
}

trap cleanup EXIT

# ── Homebrew ────────────────────────────────────────────────────

if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
else
  echo "Homebrew was not found after installation." >&2
  exit 1
fi

brew analytics off

# ── Rosetta ─────────────────────────────────────────────────────

if [[ ! -e "/Library/Apple/usr/libexec/oah/libRosettaRuntime" ]]; then
  echo
  echo "Installing Rosetta 2..."

  sudo /usr/sbin/softwareupdate --install-rosetta --agree-to-license
fi

# ── Bootstrap dependencies ───────────────────────────────────────

echo
echo "Installing bootstrap dependencies..."

brew install chezmoi 1password-cli jq
brew install --cask 1password

# ── 1Password ────────────────────────────────────────────────────

if ! op whoami >/dev/null 2>&1; then
  echo
  echo "Signing into 1Password..."
  op signin
fi

if ! op whoami >/dev/null 2>&1; then
  echo
  echo "1Password CLI is not ready."
  echo
  echo "Next:"
  echo "  1. Open 1Password and sign in."
  echo "  2. Enable Settings > Developer > Integrate with 1Password CLI."
  echo "  3. Enable the 1Password SSH agent."
  echo "  4. Re-run this bootstrap script."
  exit 0
fi

echo
echo "1Password CLI is ready."

# ── GitHub SSH ───────────────────────────────────────────────────

echo
echo "Verifying GitHub SSH access..."

SSH_OUTPUT="$(ssh -T git@github.com 2>&1 || true)"
echo "$SSH_OUTPUT"

if [[ "$SSH_OUTPUT" != *"successfully authenticated"* ]]; then
  echo
  echo "GitHub SSH authentication failed." >&2
  exit 1
fi

# ── Chezmoi ──────────────────────────────────────────────────────

CHEZMOI_SOURCE="$(chezmoi source-path)"

if [[ -d "$CHEZMOI_SOURCE/.git" ]]; then
  echo
  echo "Updating existing chezmoi configuration..."
  chezmoi update

else
  if [[ -d "$CHEZMOI_SOURCE" ]]; then
    echo
    echo "Removing incomplete chezmoi source directory..."
    rm -rf "$CHEZMOI_SOURCE"
  fi

  echo
  echo "Initializing chezmoi..."

  chezmoi init --apply "$DOTFILES_REPO"
fi

# ── Health check ──────────────────────────────────────────────────

echo
echo "Running post-bootstrap health check..."

if [[ -x "$HOME/.local/bin/mac-audit" ]]; then
  "$HOME/.local/bin/mac-audit"
else
  echo "mac-audit is not installed; skipping the health check." >&2
fi

# ── Complete ──────────────────────────────────────────────────────

echo
echo "Bootstrap completed."
echo "Review the manual setup checklist at: $CHEZMOI_SOURCE/MACOS_SETUP.md"
