---
title: "SSH_CHEATER"
date: 2026-05-31
url: /Ssh_cheater/
categories:
  - Networking
tags:
  - Cortex
draft: false
---

## CHEATER: SSH

{{< collapse "GLOBAL VARIABLES & SCOPE" >}}
```text
# SSH Reference & Workflow

**Scope:** Covers end-to-end secure SSH configuration for:
- Local Client ↔ Remote Host (dietpi)
- Client ↔ GitHub (for key distribution)
- Client ↔ AUR (Arch User Repository)
```
{{< /collapse >}}


## SECTION_SFW: CLIENT → HOST (DIETPI)

{{< collapse "CLIENT TO HOST OVERVIEW" >}}
```text
**Client:** `andro@theworkpc` (`192.168.1.157`)  
**Host:** `dietpi@dietpi` (`192.168.1.209`)  
Goal: passwordless SSH using Ed25519 + GitHub key distribution.
```
{{< /collapse >}}

{{< collapse "QUICKSTART (NEW PI)" >}}
```bash
# On the Pi console
mkdir -p ~/.ssh && chmod 700 ~/.ssh
curl -s [https://github.com/4ndr0666.keys](https://github.com/4ndr0666.keys) >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```
{{< /collapse >}}

{{< collapse "CLIENT CONFIGURATION" >}}
```text
~/.ssh/config:
```

```sshconfig
Host dietpi
    HostName 192.168.1.209
    User dietpi
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
    StrictHostKeyChecking yes
    HashKnownHosts yes
    HostKeyAlgorithms ssh-ed25519
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

```text
Then:
```

```bash
mkdir -p ~/.ssh/sockets && chmod 700 ~/.ssh/sockets
ssh dietpi
```
{{< /collapse >}}

{{< collapse "VERIFY CONNECTION ONCE" >}}
```bash
ssh -vvv -o ControlMaster=no -o ControlPath=none dietpi \
| grep -E 'Server host key|Authenticated|using "publickey"'
```

```text
Expect:

Server host key: ssh-ed25519 SHA256:euCxRZVZ...
Authenticated ... using "publickey"
```
{{< /collapse >}}

{{< collapse "HARDEN THE PI (SERVER-SIDE)" >}}
```bash
sudo sed -i \
  -e 's/^[# ]*PasswordAuthentication.*/PasswordAuthentication no/' \
  -e 's/^[# ]*KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/' \
  -e 's/^[# ]*PubkeyAuthentication.*/PubkeyAuthentication yes/' \
  -e 's/^[# ]*PermitRootLogin.*/PermitRootLogin no/' \
  /etc/ssh/sshd_config
sudo systemctl restart ssh
```
{{< /collapse >}}

{{< collapse "MULTIPLEXING NOTES" >}}
```text
* Reuses one authenticated TCP session for instant new shells or scp/sftp.
* Requires `~/.ssh/sockets` (chmod 700).
* Not a sandbox — it’s performance and reliability.

Control commands:
```

```bash
ssh -O check dietpi   # Is master running?
ssh -O exit  dietpi   # Close master session
```
{{< /collapse >}}

{{< collapse "MINI-AUDIT (REPEAT ANYTIME)" >}}
```text
Run these mini-audits to verify your configuration.
```

<details class="glass-panel p-3 mt-4 border-hud" style="background: rgba(0, 229, 255, 0.05) !important;">
<summary class="text-cyan fw-bold" style="cursor: pointer; font-family: var(--primary_font); list-style: none;">[ + ] ON THE PI</summary>

```bash
whoami
sudo journalctl -u ssh -n 50 --no-pager | grep -i 'Accepted publickey' || echo 'NO publickey events seen'
ls -ld ~/.ssh; ls -l ~/.ssh/authorized_keys; head -n 2 ~/.ssh/authorized_keys
sudo sshd -T | grep -E '^(passwordauthentication|kbdinteractiveauthentication|pubkeyauthentication)'
sudo ssh-keygen -l -f /etc/ssh/ssh_host_ed25519_key.pub
systemctl is-active ssh; systemctl is-enabled ssh
ss -tnlp | grep ':22'
```

</details>

<details class="glass-panel p-3 mt-4 border-hud" style="background: rgba(0, 229, 255, 0.05) !important;">
<summary class="text-cyan fw-bold" style="cursor: pointer; font-family: var(--primary_font); list-style: none;">[ + ] ON THE CLIENT</summary>

```bash
ls -ld ~/.ssh/sockets || (mkdir -p ~/.ssh/sockets && chmod 700 ~/.ssh/sockets)
ssh -G dietpi | grep -E 'control(master|path|persist)|serveralive(interval|countmax)'
ssh-keygen -F 192.168.1.209
ssh -o PubkeyAuthentication=no -o PasswordAuthentication=yes dietpi || echo 'OK: passwords disabled'
```

</details>
{{< /collapse >}}

{{< collapse "KEY MANAGEMENT" >}}
```bash
ssh-keygen -t ed25519 -a 100 -C "andro@theworkpc"
cat ~/.ssh/id_ed25519.pub

chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```
{{< /collapse >}}

{{< collapse "TROUBLESHOOTING" >}}
```bash
ssh -vvv dietpi
ssh-keygen -R 192.168.1.209
ssh-keyscan -t ed25519 192.168.1.209 >> ~/.ssh/known_hosts
ssh-keygen -H -f ~/.ssh/known_hosts && rm -f ~/.ssh/known_hosts.old
eval "$(ssh-agent -s)"; ssh-add ~/.ssh/id_ed25519
```
{{< /collapse >}}


## SECTION_SFW: AUR (ARCH USER REPOSITORY) WORKFLOW

{{< collapse "AUR WORKFLOW OVERVIEW" >}}
```text
**Purpose:** Access, clone, and manage AUR packages via SSH with your Ed25519 key.
```
{{< /collapse >}}

{{< collapse "SETUP ONCE" >}}
```text
1. Upload your public key (`~/.ssh/id_ed25519.pub`) to your AUR profile:
   [https://aur.archlinux.org/account/USERNAME/edit](https://aur.archlinux.org/account/USERNAME/edit)

2. Add to `~/.ssh/config`:
```

```sshconfig
Host aur.archlinux.org
    User aur
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
    HostKeyAlgorithms ssh-ed25519
    StrictHostKeyChecking yes
    HashKnownHosts yes
```

```text
3. Pin host key:
```

```bash
ssh-keyscan aur.archlinux.org >> ~/.ssh/known_hosts
ssh-keygen -H -f ~/.ssh/known_hosts
```
{{< /collapse >}}

{{< collapse "VERIFY AUR ACCESS" >}}
```bash
ssh -T aur@aur.archlinux.org help
```

```text
Expected:

Commands:
  adopt <name> ...
  git-upload-pack
  git-receive-pack
  ...

If you see that, you’re fully authenticated.
```
{{< /collapse >}}

{{< collapse "COMMON AUR COMMANDS" >}}
```text
| Purpose         | Command                                               | Notes                          |
| --------------- | ----------------------------------------------------- | ------------------------------ |
| List your repos | `ssh aur@aur.archlinux.org list-repos`                | View all packages you maintain |
| Clone package   | `git clone ssh://aur@aur.archlinux.org/<pkgname>.git` | Pulls AUR repo locally         |
| Push update     | `git push aur master`                                 | Publishes new PKGBUILD         |
| Flag outdated   | `ssh aur@aur.archlinux.org flag <pkg> "reason"`       | Marks package as out-of-date   |
| Vote            | `ssh aur@aur.archlinux.org vote <pkg>`                | Adds your vote                 |
| Disown/adopt    | `ssh aur@aur.archlinux.org disown <pkg>`              | Manage maintainership          |

All use the same Ed25519 key.
```
{{< /collapse >}}

{{< collapse "TEST AUTOMATION" >}}
```bash
ssh -T aur@aur.archlinux.org help >/dev/null 2>&1 && echo "✅ AUR SSH OK" || echo "❌ AUR SSH FAIL"
```
{{< /collapse >}}


## SECTION_SFW: HARDENED SSH_SETUP.SH

{{< collapse "HARDENED SCRIPT" >}}
```bash
#!/usr/bin/env bash
# Author: 4ndr0666
# Purpose: Install GitHub-hosted SSH keys into ~/.ssh/authorized_keys on the local host.
# Usage:   curl -fsSL [https://raw.githubusercontent.com/4ndr0666/docs/main/ssh_setup.sh](https://raw.githubusercontent.com/4ndr0666/docs/main/ssh_setup.sh) | bash
set -euo pipefail

USER_KEYS_URL="${1:-[https://github.com/4ndr0666.keys](https://github.com/4ndr0666.keys)}"

umask 077
mkdir -p "${HOME}/.ssh"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
curl -fsSL "$USER_KEYS_URL" > "$tmp"

touch "${HOME}/.ssh/authorized_keys"
awk 'NF' "${HOME}/.ssh/authorized_keys" "$tmp" | sort -u > "${HOME}/.ssh/authorized_keys.new"
mv "${HOME}/.ssh/authorized_keys.new" "${HOME}/.ssh/authorized_keys"

chmod 700 "${HOME}/.ssh"
chmod 600 "${HOME}/.ssh/authorized_keys"

echo "✅ Installed keys from: $USER_KEYS_URL"
```

<details class="glass-panel p-3 mt-4 border-hud" style="background: rgba(0, 229, 255, 0.05) !important;">
<summary class="text-cyan fw-bold" style="cursor: pointer; font-family: var(--primary_font); list-style: none;">[ + ] EXPAND_NOTES_AND_ALT_SOURCE</summary>

```text
* **Idempotent** – safe to rerun anytime
* **Portable** – works on any Linux/Unix host
* **Reproducible** – deterministic permissions & key order

Example alt-source:
```

```bash
curl -fsSL https://…/ssh_setup.sh | bash -s -- [https://gist.githubusercontent.com/](https://gist.githubusercontent.com/)<id>/raw/key.pub
```

</details>
{{< /collapse >}}


## SECTION_SFW: MENTAL MODEL SUMMARY & CONCLUSION

{{< collapse "MENTAL MODEL SUMMARY" >}}
```text
| Concept                 | Analogy           | Key takeaway                 |
| ----------------------- | ----------------- | ---------------------------- |
| `authorized_keys`       | Lock whitelist    | Determines who can enter     |
| `known_hosts`           | Handshake logbook | Proves who you’re talking to |
| `ControlMaster`         | Connection pool   | Performance optimization     |
| `id_ed25519`            | Private identity  | Never leave your machine     |
| GitHub `.keys` endpoint | Cloud keyring     | Canonical public source      |
| AUR SSH                 | Command gate      | No shell, just RPC commands  |
```
{{< /collapse >}}

{{< collapse "CONCLUSION" >}}
```text
**✅ You are now production-aligned.**

* Secure keypair (Ed25519)
* Deterministic permissions
* Verified host identity
* GitHub/AUR integration
* Audit reproducibility
```
{{< /collapse >}}
