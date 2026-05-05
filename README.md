# Desktop-server-codex-05-05

This repo documents a temporary server on a desktop, built by Codex, and keeps
the current state and the remaining work in one place.

Start here:

- [PROJECT-OVERVIEW.md](./PROJECT-OVERVIEW.md)
- [docs/control-panel.md](./docs/control-panel.md)
- [docs/codex-cli-todo.md](./docs/codex-cli-todo.md)

## Current Build

| Item | Value |
|------|-------|
| Host | Desktop Proxmox node `home-lab` at `192.168.0.10` |
| DNS | Pi-hole at `192.168.0.30` for local testing |
| HTTPS proxy | Nginx Proxy Manager at `192.168.0.31` |
| Home Assistant | LXC `120 ha` at `192.168.0.20` |
| ZimaOS | VM `102 zimaos` at `192.168.0.22` |
| Codex VM | VM `104 codex-agent` at `192.168.0.23` |

## What Is Done

- Proxmox is installed and reachable on the desktop host.
- SSH key auth to the host is working.
- Home Assistant, Pi-hole, Nginx Proxy Manager, ZimaOS, and the Codex VM are up.
- The Codex VM browser console is available at `http://ai.home/vnc.html?autoconnect=true&resize=remote`.
- `.home` records exist for `ai.home` and `pihole.home` in direct Pi-hole testing.
- The repo docs have been updated to match the live build.

## What Is Planned

- Finalize local DNS naming and decide the long-term HTTPS naming scheme.
- Confirm or change the Nginx Proxy Manager admin login; the current username
  and password are stored in Bitwarden.
- Attach external storage for ZimaOS data and backups.
- Configure ZimaOS apps and backup jobs.
- Review GPU passthrough and Ollama only if the AI VM needs local model work.
- Add proxy hosts for the services that need friendly URLs.

## Repo Structure

| Path | Purpose |
|------|---------|
| `AGENTS.md` | Official Codex project instructions |
| `codex.md` | Repo map and operator entrypoint |
| `docs/` | Human docs, runbooks, and project status pages |
| `scripts/` | Proxmox-side helper scripts |
| `ansible/` | Repeatable guest configuration playbooks |
| `proxy/` | Nginx Proxy Manager Docker Compose files |
| `rules/` | Repo-specific operational and safety rules |

## Primary Docs

| File | Purpose |
|------|---------|
| `PROJECT-OVERVIEW.md` | Friendly project overview |
| `docs/control-panel.md` | Current-state tracker |
| `docs/home-lab-structure.md` | Target architecture |
| `docs/codex-cli-todo.md` | Codex CLI execution checklist |
| `docs/codex-cli-ssh-execution.md` | SSH/Ansible execution guide |
| `docs/https-local-npm.md` | Nginx Proxy Manager HTTPS runbook |
| `docs/ai-vm-ollama.md` | AI VM, GPU passthrough, and Ollama runbook |

## Automation

| File | Description |
|------|-------------|
| `scripts/create-proxy-lxc.sh` | Creates Debian LXC `131 proxy` at `192.168.0.31` |
| `scripts/create-pihole-lxc.sh` | Creates Debian LXC `130 pihole` at `192.168.0.30` |
| `scripts/create-home-assistant-lxc.sh` | Creates Debian LXC `120 ha` at `192.168.0.20` |
| `ansible/install-nginx-proxy-manager.yml` | Installs Docker and Nginx Proxy Manager inside `proxy` |
| `ansible/install-pihole.yml` | Installs and configures Pi-hole |
| `ansible/install-home-assistant.yml` | Installs Home Assistant Core |
| `ansible/install-ollama-ai.yml` | Installs Ollama and tests `qwen2.5:0.5b-base` on the `codex-agent` VM |

## DNS And Local HTTPS Plan

Current DNS state:

| Name | Target | Status |
|------|--------|--------|
| `ai.home` | `192.168.0.31` | Confirmed via Pi-hole direct query |
| `pihole.home` | `192.168.0.30` | Confirmed via Pi-hole direct query |
| Router/DHCP DNS | `192.168.0.30` | Not changed yet |

Use `.home` for current local testing. Keep the Cloudflare-backed
`lab.yourdomain.com` style names below as the future trusted HTTPS plan.

| DNS Name | Local Target |
|----------|--------------|
| `proxmox.lab.yourdomain.com` | `https://192.168.0.10:8006` |
| `ha.lab.yourdomain.com` | `http://192.168.0.20:8123` |
| `zima.lab.yourdomain.com` | `http://192.168.0.22` |
| `pihole.lab.yourdomain.com` | `http://192.168.0.30/admin/` |
| `hub.lab.yourdomain.com` | TBD after hub migration |
| `trip.lab.yourdomain.com` | TBD after trip-logger migration |

Router ports `80` and `443` should stay closed for this local-only setup.

## AI VM Plan

VM `104 codex-agent` is the current AI VM project.

| Field | Value |
|-------|-------|
| VM ID | `104` |
| VM name | `codex-agent` |
| IP | `192.168.0.23` |
| OS | Ubuntu 24.04.4 LTS |
| SSH user | `root` |
| Sudo | yes |
| Browser access | `http://ai.home/vnc.html?autoconnect=true&resize=remote` |
| Role | local AI workstation / Codex agent experiments |

## Safety Rules

- Do not expose Proxmox directly to the internet.
- Do not open router ports `80` or `443` unless the local-only plan changes.
- Do not commit Cloudflare tokens, passwords, SSH keys, or Bitwarden secrets.
- Keep VM system disks on internal Proxmox storage.
- Use the external enclosure for data only.
- Back up HAOS, ZimaOS, hub, and trip-logger before replacing old services.

## Recommended Operator Flow

1. Read `PROJECT-OVERVIEW.md`.
2. Read `docs/control-panel.md` for the live status.
3. Read `docs/codex-cli-todo.md` for the step-by-step checklist.
4. Confirm SSH to `root@192.168.0.10`.
5. Confirm VM `104 codex-agent` SSH and AI tooling from the operator machine.
6. Keep router/firewall DNS unchanged until the project is ready for a broader cutover.
7. Finish the local DNS and HTTPS plan.
8. Attach external storage and set up ZimaOS apps and backups.
9. Add proxy hosts for the services that need clean URLs.

## Validation

When tools are available:

```bash
shellcheck scripts/*.sh
ansible-playbook --syntax-check ansible/install-nginx-proxy-manager.yml
ansible-playbook --syntax-check ansible/install-pihole.yml
ansible-playbook --syntax-check ansible/install-home-assistant.yml
ansible-playbook --syntax-check ansible/install-ollama-ai.yml
```

If those tools are not installed, manually inspect the changed script/playbook
and update the relevant docs.
