# Dotfiles

Personal macOS configuration managed with [chezmoi](https://www.chezmoi.io/).

The goal of this repository is to make configuring a new Mac reproducible while keeping secrets and machine-specific credentials outside of Git.

## Overview

The setup uses:

- **chezmoi** — dotfile and configuration management
- **Homebrew** — package and application management
- **1Password** — secrets, SSH keys, and Git signing
- **Oh My Zsh** — Zsh configuration and plugins
- **Starship** — shell prompt
- **PowerChest** — macOS system preferences

## Bootstrap

The bootstrap currently supports Apple Silicon Macs.

On a new Mac, run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/glenflorendo/dotcentral/main/bootstrap.sh)"
```

The bootstrap will request administrator privileges at the beginning and keep the `sudo` credentials active while it runs. Some macOS services, such as the Mac App Store, may still request authentication independently.

The bootstrap process:

1. Verifies that the machine is running macOS on Apple Silicon.
2. Requests administrator privileges.
3. Installs Homebrew if necessary.
4. Disables Homebrew analytics.
5. Installs Rosetta 2 if necessary.
6. Installs the bootstrap dependencies:
   - chezmoi
   - 1Password
   - 1Password CLI
   - jq
7. Verifies that 1Password CLI is authenticated.
8. Verifies GitHub SSH access through the 1Password SSH agent.
9. Initializes and applies the chezmoi repository.
10. Installs packages and applications from the Brewfile.
11. Installs additional software managed outside Homebrew.
12. Runs a non-destructive post-bootstrap health check.

The script is designed to be rerun safely. If the chezmoi source repository already exists, it is updated instead of initialized again.

### 1Password setup

The first bootstrap run may require 1Password to be configured before provisioning can continue.

In 1Password:

1. Sign in to the appropriate account.
2. Open **Settings → Developer**.
3. Enable **Integrate with 1Password CLI**.
4. Enable the **SSH Agent**.
5. Allow the SSH agent to use the GitHub authentication/signing key.

Secrets and personal configuration required by chezmoi templates are retrieved from 1Password and are not stored directly in this repository.

### GitHub SSH

The dotfiles repository is cloned over SSH.

During the first connection to GitHub on a new Mac, SSH may ask you to verify GitHub's host key:

```text
The authenticity of host 'github.com' can't be established.
...
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

Verify the fingerprint against GitHub's published SSH host-key fingerprints before accepting it.

Afterward, successful authentication should report:

```text
Hi USERNAME! You've successfully authenticated, but GitHub does not provide shell access.
```

The host key is stored in `~/.ssh/known_hosts`, so this confirmation is normally required only once.

## macOS preferences

macOS preferences are managed using [PowerChest](https://powerchest.app/).

PowerChest is installed directly from its latest GitHub release because it is not currently managed through the Brewfile.

The repository contains:

```text
macos.powerchestprofile
```

After bootstrap completes, open the profile:

```bash
open "$(chezmoi source-path)/macos.powerchestprofile"
```

Review the proposed changes in PowerChest before applying them.

Applying the PowerChest profile remains an intentional manual step so system-level changes can be reviewed before they are made.

## Health check and manual setup

The bootstrap finishes by running an offline, non-destructive audit:

```bash
mac-audit
```

It checks chezmoi state, Brewfile dependencies, 1Password CLI authentication, FileVault, the application firewall, stealth mode, and Remote Login. Findings are reported as passes, warnings, or failures without changing settings or failing the bootstrap.

Network-dependent checks are opt-in:

```bash
mac-audit --network
```

This also verifies GitHub SSH authentication and asks macOS Software Update whether updates are available.

Settings that require authentication, physical presence, privacy consent, or a machine-specific decision are documented in:

```text
MACOS_SETUP.md
```

Review this checklist after provisioning a new Mac. It covers Apple Account and recovery settings, FileVault, privacy permissions, application accounts, hardware, and backups.

## Updating

Pull the latest dotfiles and apply them:

```bash
chezmoi update
```

Preview pending changes:

```bash
chezmoi diff
```

Apply local source changes:

```bash
chezmoi apply
```

The full bootstrap script can also be safely rerun when provisioning or repairing a machine:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/glenflorendo/dotcentral/main/bootstrap.sh)"
```

## Repository structure

```text
.
├── .chezmoiignore
├── .chezmoiscripts/
├── bootstrap.sh
├── Brewfile
├── MACOS_SETUP.md
├── dot_config/
├── dot_local/bin/mac-audit
├── dot_gitconfig.tmpl
├── dot_zprofile
├── dot_zshrc
├── macos.powerchestprofile
├── private_dot_ssh/
└── README.md
```

### Repository-only files

Some files belong to the repository but should not be copied into the home directory. These are listed in `.chezmoiignore`, including:

```text
bootstrap.sh
Brewfile
MACOS_SETUP.md
README.md
macos.powerchestprofile
```

## Package management

Packages and applications are declared in `Brewfile`.

When the Brewfile changes, chezmoi runs:

```bash
brew bundle --file="$(chezmoi source-path)/Brewfile"
```

through a `run_onchange` chezmoi script.

Some packages require Rosetta 2 on Apple Silicon. The bootstrap installs Rosetta before chezmoi processes the Brewfile.

Mac App Store applications are installed through `mas`. macOS may request Apple Account authentication while these applications are being installed.

## Shell

The Zsh configuration is organized as:

```text
~/.zprofile
~/.zshrc
~/.config/zsh/
├── aliases.zsh
└── omz.zsh
```

`.zprofile` manages login-shell environment configuration and PATH setup.

`.zshrc` initializes the interactive shell, including Oh My Zsh and Starship.

Oh My Zsh and its external plugins are installed automatically through a chezmoi `run_once` script.

## Git and SSH

Git uses SSH for GitHub authentication and for commit and tag signing.

The SSH agent and signing program are provided by 1Password. Private SSH key material is not stored in this repository or copied into `~/.ssh`.

chezmoi templates retrieve the required Git identity and public signing-key information from 1Password when configuration is applied.

GitHub SSH access can be verified with:

```bash
ssh -T git@github.com
```
