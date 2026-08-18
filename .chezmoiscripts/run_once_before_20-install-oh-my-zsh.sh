#!/bin/bash

set -euo pipefail

ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$ZSH_DIR/custom}"

if [[ ! -d "$ZSH_DIR" ]]; then
  echo "Installing Oh My Zsh..."

  RUNZSH=no CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended
fi

if [[ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" ]]; then
  echo "Installing zsh-autosuggestions..."

  git clone \
    https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
fi

if [[ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting" ]]; then
  echo "Installing zsh-syntax-highlighting..."

  git clone \
    https://github.com/zsh-users/zsh-syntax-highlighting \
    "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
fi
