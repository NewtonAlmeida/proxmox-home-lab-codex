# Desktop-server-codex-05-05 Repo Index

This is the durable map for Codex and the human operator. `AGENTS.md` stays the
primary instruction file; this page explains the project shape and where to read
next.

## Current Project

Build and document a temporary server on a desktop, with Codex managing the
current state and the remaining tasks.

## Current Stage - 2026-05-05

| Component | State |
|-----------|-------|
| Desktop Proxmox host | `home-lab` is running at `192.168.0.10`; SSH key auth works with `~/.ssh/home-lab-codex`. |
| ZimaOS | VM `102 zimaos` is running at `192.168.0.22`. |
| Home Assistant | LXC `120 ha` is running at `192.168.0.20:8123`. |
| Pi-hole | LXC `130 pihole` is running at `192.168.0.30/admin/`; direct DNS queries to `192.168.0.30` work. Router/DHCP DNS cutover is not done. |
| Nginx Proxy Manager | LXC `131 proxy` is running at `192.168.0.31:81`. |
| Codex VM | VM `104 codex-agent` is running at `192.168.0.23`; browser access is `http://ai.home/vnc.html?autoconnect=true&resize=remote`; Ubuntu 24.04.4 LTS, root SSH user, sudo installed. |
| DNS | Current local testing uses `.home` records in Pi-hole/Windows context. Confirmed: `ai.home -> 192.168.0.31`, `pihole.home -> 192.168.0.30`. |
| Local HTTPS | Pending Cloudflare DNS challenge, final local DNS records, and NPM proxy hosts. |
| External storage | Pending; no external USB storage was detected during deployment. |

## Project Map

| Path | Purpose |
|------|---------|
| `PROJECT-OVERVIEW.md` | Friendly project overview |
| `README.md` | Root readme and entry point |
| `AGENTS.md` | Official Codex instructions |
| `docs/` | Human docs, runbooks, and project status pages |
| `scripts/` | Proxmox-side helper scripts |
| `ansible/` | Repeatable guest configuration playbooks |
| `proxy/` | Nginx Proxy Manager Docker Compose files |
| `rules/` | Repo-specific operational and safety rules |

## Main Docs

| File | Purpose |
|------|---------|
| `docs/control-panel.md` | Current-state tracker |
| `docs/home-lab-structure.md` | Target architecture and service order |
| `docs/codex-cli-todo.md` | Step-by-step execution checklist |
| `docs/codex-cli-ssh-execution.md` | SSH and Ansible execution guide |
| `docs/https-local-npm.md` | Local HTTPS runbook |
| `docs/ai-vm-ollama.md` | AI VM and Ollama runbook |

## What Is Done

- Proxmox is installed and reachable on the desktop host.
- SSH key-based admin access works.
- Home Assistant, Pi-hole, Nginx Proxy Manager, ZimaOS, and the Codex VM are up.
- The repo docs have been updated to track the live state.

## What Is Planned

- Finish local DNS naming and the HTTPS plan.
- Confirm or change the Nginx Proxy Manager admin login.
- Attach and validate the external storage path for ZimaOS data.
- Configure ZimaOS apps and backup jobs.
- Review GPU passthrough and Ollama validation only if the AI VM needs local model work.
- Add or refine service proxy hosts as the project expands.

## Next Operator Path

1. Read `PROJECT-OVERVIEW.md`.
2. Read `docs/control-panel.md`.
3. Read `docs/codex-cli-todo.md`.
4. Confirm SSH to `root@192.168.0.10`.
5. Confirm the Codex VM and AI tooling from the operator machine.
6. Keep router/DHCP DNS unchanged until the project is ready for a broader cutover.
7. Finish the local DNS and HTTPS plan.
8. Attach external storage and set up ZimaOS apps and backups.
9. Add proxy hosts for the services that need clean URLs.

## Notes

OpenAI Codex discovers `AGENTS.md` files automatically. `codex.md` remains the
project index, not the primary instruction file, unless a Codex config adds it
as a fallback filename.

