# SSH Setup On The Other PC

## Required SSH Targets

```sshconfig
Host home-lab
  HostName 192.168.0.10
  User root
  IdentityFile ~/.ssh/home-lab-codex
  BatchMode yes
  StrictHostKeyChecking accept-new

Host lab2
  HostName 192.168.0.11
  User root
```

`home-lab` should use a normal SSH key file. `lab2` uses the user's Bitwarden
SSH agent, so do not force `BatchMode=yes` for `lab2` until key access is fully
confirmed.

## Test Commands

After powering on `home-lab`, run:

```bash
ssh home-lab "hostname && pveversion"
ssh lab2 "hostname && pveversion"
```

If `home-lab` fails with too many SSH identities, use:

```bash
ssh -i ~/.ssh/home-lab-codex -o IdentitiesOnly=yes home-lab "hostname && pveversion"
```

## Safety Rules

- Do not copy private SSH keys into this repository.
- Do not commit Bitwarden exports or tokens.
- Do not put passwords in Markdown files.
- If SSH access to `lab2` prompts through Bitwarden, allow the prompt manually.

