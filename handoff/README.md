# Proxmox Home Lab Handoff

Start here when continuing this project on another PC with Codex.

## What This Folder Is

This folder is the portable handoff for the Proxmox migration. It is safe to
commit to GitHub because it contains instructions and state only. It does not
contain SSH keys, passwords, Cloudflare tokens, Bitwarden secrets, or Pi-hole
passwords.

## Read Order On The Other PC

1. `current-state.md`
2. `ssh-setup.md`
3. `backup-plan.md`
4. `manual-backups.md`
5. `next-steps.md`
6. `resume-prompt.md`

## One-Line Prompt For The Other Codex

```text
Open this repo, read handoff/README.md first, then continue the Proxmox migration using the handoff files as the source of truth.
```

## Important Limits

- The other PC must be on the same LAN or VPN as the lab.
- The other PC must be able to reach `192.168.0.10` and `192.168.0.11`.
- SSH keys and Bitwarden SSH agent access must be configured on that PC.
- Do not commit secrets to this repo.

