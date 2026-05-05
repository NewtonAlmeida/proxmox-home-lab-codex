# Desktop-server-codex-05-05 Control Panel

## Project Overview

| Item | Value |
|------|-------|
| Project | `Desktop-server-codex-05-05` |
| Purpose | Temporary server on a desktop, built by Codex |
| Proxmox host | `home-lab` @ `192.168.0.10` |
| VM range | `192.168.0.20-29` |
| LXC range | `192.168.0.30-39` |
| HTTPS proxy | `proxy` @ `192.168.0.31` |
| Codex VM | `104 codex-agent` @ `192.168.0.23` |

## Current State - 2026-05-05

| Component | State | URL / Note |
|-----------|-------|------------|
| Proxmox | Running | `https://192.168.0.10:8006` |
| Codex VM | Running | VM `104 codex-agent`; browser `http://ai.home/vnc.html?autoconnect=true&resize=remote`; Ubuntu 24.04.4 LTS, root SSH, sudo installed |
| ZimaOS | Running | `http://192.168.0.22` |
| Home Assistant | Running | `http://192.168.0.20:8123` |
| Pi-hole | Running | `http://192.168.0.30/admin/`; direct DNS works, router DNS not cut over |
| Nginx Proxy Manager | Running | `http://192.168.0.31:81` |
| Local DNS | Partial | `.home` local testing; confirmed `ai.home -> 192.168.0.31`, `pihole.home -> 192.168.0.30` |
| Local HTTPS | Planned | Needs Cloudflare DNS challenge, final DNS records, and proxy hosts |
| External USB storage | Planned | No external storage detected during deployment |

## Done

- Proxmox is installed and reachable on the desktop host.
- SSH key access to the host works.
- Home Assistant, Pi-hole, Nginx Proxy Manager, ZimaOS, and the Codex VM are running.
- The Codex VM browser console is available.
- The repo docs have been updated to reflect the live state.

## Planned

- Confirm or change the Nginx Proxy Manager admin login.
- Decide whether router/DHCP DNS should stay local-only or be cut over later.
- Finish the local DNS and HTTPS naming plan.
- Attach external storage and configure ZimaOS apps and backups.
- Revisit GPU passthrough and Ollama validation if the Codex VM needs local model work.
- Add proxy hosts for services that need friendly URLs.

## Short Links

| File | Purpose |
|------|---------|
| [PROJECT-OVERVIEW.md](../PROJECT-OVERVIEW.md) | Friendly project summary |
| [README.md](../README.md) | Root entry point |
| [docs/home-lab-structure.md](./home-lab-structure.md) | Architecture and service layout |
| [docs/codex-cli-todo.md](./codex-cli-todo.md) | Execution checklist |
| [docs/https-local-npm.md](./https-local-npm.md) | Local HTTPS runbook |

