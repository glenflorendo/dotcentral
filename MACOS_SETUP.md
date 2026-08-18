# macOS manual setup checklist

These steps require user authentication, physical presence, privacy consent, or a decision specific to the computer. They are intentionally not automated by chezmoi.

## Apple Account and recovery

- [ ] Sign in to the correct Apple Account.
- [ ] Enable **Find My Mac** and verify that the Mac appears in Find My.
- [ ] Review iCloud Drive, Photos, Keychain, Messages, and Private Relay settings.
- [ ] Configure account recovery contacts or a recovery key as appropriate.

## Disk and account security

- [ ] Enable FileVault and store its recovery key somewhere separate and secure.
- [ ] Add fingerprints to Touch ID.
- [ ] Require a password immediately after the display turns off or the screen saver starts.
- [ ] Confirm the Guest User account and sharing-only accounts are disabled unless needed.
- [ ] Review **Privacy & Security → Security** and the automatic update policy.

## Privacy permissions

Grant only the permissions required by applications you trust. Common permissions to review include:

- [ ] Accessibility
- [ ] Full Disk Access
- [ ] Screen & System Audio Recording
- [ ] Input Monitoring
- [ ] Automation
- [ ] Camera and microphone
- [ ] Files and folders
- [ ] Location Services

Do not automate these by directly modifying the macOS TCC database. macOS protects these decisions and unsupported changes can weaken security or break across OS updates.

## 1Password, Git, and SSH

- [ ] Sign in to 1Password.
- [ ] Enable **Settings → Developer → Integrate with 1Password CLI**.
- [ ] Enable the 1Password SSH agent.
- [ ] Allow the intended key to authenticate to and sign commits for GitHub.
- [ ] Run `ssh -T git@github.com` and verify GitHub's host-key fingerprint before accepting it.

## Applications and accounts

- [ ] Sign in to required browser profiles and review browser synchronization.
- [ ] Sign in to communication and productivity applications.
- [ ] Configure Google Drive folders and streaming or mirroring behavior.
- [ ] Activate paid application licenses.
- [ ] Select default applications for web, email, calendar, media, and common document types.
- [ ] Review each application's launch-at-login setting.

## Hardware and workspace

- [ ] Pair Bluetooth keyboards, pointing devices, headphones, and other accessories.
- [ ] Configure display arrangement, scaling, refresh rate, HDR, and Night Shift.
- [ ] Select preferred sound input, output, and alert devices.
- [ ] Add and test printers or scanners.
- [ ] Review laptop battery and power settings.

## Backups

- [ ] Configure and encrypt a Time Machine destination.
- [ ] Complete an initial backup.
- [ ] Verify that important cloud and local folders are included in a backup strategy.
- [ ] Test access to recovery keys and backup credentials.

## Verification

Run the local audit after completing the checklist:

```bash
mac-audit --network
```

The audit is read-only and reports warnings without changing system settings.
