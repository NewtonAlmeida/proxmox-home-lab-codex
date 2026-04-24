# Proxmox Home Lab Codex

Documentation, runbooks, and automation for migrating a home lab into a single bare-metal Proxmox host.

The repo is organized for both a human operator and Codex CLI. It includes architecture notes, a Codex instruction file, SSH execution checklists, Ansible playbooks, and helper scripts for the first services.

## Target Architecture

| Item | Value |
|------|-------|
| Proxmox hostname | `home-lab` |
| Proxmox IP | `192.168.0.10/24` |
| Gateway | `192.168.0.1` |
| DNS | `192.168.0.1` |
| RAM | 16GB |
| HTTPS proxy | Nginx Proxy Manager |
| Proxy IP | `192.168.0.31` |
| AI VM | `ai` at `192.168.0.23` |

## Network Plan

| Range | Purpose |
|-------|---------|
| `192.168.0.10-19` | Proxmox and management |
| `192.168.0.20-29` | VMs |
| `192.168.0.30-39` | LXC containers |
| `192.168.0.40-99` | Network devices |
| `192.168.0.100-199` | Apps and temporary services |
| `192.168.0.200-249` | Workstations and user devices |

## Planned Services

| ID | Name | Type | IP | Purpose |
|----|------|------|----|---------|
| Host | `home-lab` | Proxmox | `192.168.0.10` | Hypervisor |
| 100 | `hub` | VM | `192.168.0.20` | Gemini management hub |
| 101 | `haos` | VM | `192.168.0.21` | Home Assistant OS |
| 102 | `zimaos` | VM | `192.168.0.22` | NAS and app platform |
| 104 | `ai` | VM | `192.168.0.23` | Ollama with exclusive GPU passthrough |
| 103 | `trip-logger` | LXC | `192.168.0.30` | Small service |
| 131 | `proxy` | LXC | `192.168.0.31` | Nginx Proxy Manager |

## Repository Structure

| Path | Purpose |
|------|---------|
| `AGENTS.md` | Official Codex project instructions |
| `codex.md` | Repo map and operator entrypoint |
| `docs/` | Human docs, runbooks, and migration checklists |
| `scripts/` | Proxmox-side helper scripts |
| `ansible/` | Repeatable guest configuration playbooks |
| `proxy/` | Nginx Proxy Manager Docker Compose files |
| `rules/` | Safety and Codex workflow rules |

## Important Docs

| File | Purpose |
|------|---------|
| `docs/documentation.md` | Editable human summary |
| `docs/home-lab-structure.md` | Full target architecture |
| `docs/codex-cli-todo.md` | Step-by-step Codex CLI checklist |
| `docs/codex-cli-ssh-execution.md` | SSH and Ansible execution guide |
| `docs/https-local-npm.md` | Local HTTPS with Nginx Proxy Manager |
| `docs/ai-vm-ollama.md` | AI VM, GPU passthrough, and Ollama |

## Automation

| File | Description |
|------|-------------|
| `scripts/create-proxy-lxc.sh` | Creates Debian LXC `131 proxy` at `192.168.0.31` |
| `ansible/install-nginx-proxy-manager.yml` | Installs Docker and Nginx Proxy Manager inside `proxy` |
| `ansible/install-ollama-ai.yml` | Installs Ollama and tests `qwen2.5:0.5b-base` on the `ai` VM |

## Local HTTPS Plan

The lab uses Nginx Proxy Manager locally, with Cloudflare DNS challenge certificates.

| DNS Name | Local Target |
|----------|--------------|
| `proxmox.lab.yourdomain.com` | `https://192.168.0.10:8006` |
| `haos.lab.yourdomain.com` | `http://192.168.0.21:8123` |
| `zima.lab.yourdomain.com` | `http://192.168.0.22` |
| `hub.lab.yourdomain.com` | `http://192.168.0.20` |
| `trip.lab.yourdomain.com` | `http://192.168.0.30` |

Router ports `80` and `443` should stay closed for this local-only setup.

## AI VM Plan

The `ai` VM must be tested before continuing the rest of the migration.

Rules:

- VM ID: `104`
- IP: `192.168.0.23`
- GPU passthrough belongs only to this VM
- Install Ollama
- Test small model `qwen2.5:0.5b-base`
- Stop other migration work if the small model test fails

## Safety Rules

- Do not expose Proxmox directly to the internet.
- Do not open router ports `80` or `443` unless the local-only plan changes.
- Do not commit Cloudflare tokens, passwords, SSH keys, or Bitwarden secrets.
- Keep VM system disks on internal Proxmox storage.
- Use the external enclosure for data only.
- Back up HAOS, ZimaOS, hub, and trip-logger before replacing old services.

## Recommended Operator Flow

1. Read `AGENTS.md` and `codex.md`.
2. Follow `docs/codex-cli-todo.md`.
3. Confirm SSH to `root@192.168.0.10`.
4. Create and validate VM `104 ai`.
5. Install Ollama and run the small model test.
6. Create LXC `131 proxy`.
7. Install Nginx Proxy Manager.
8. Configure local DNS and Cloudflare DNS challenge certificates.
9. Continue migration of HAOS, trip-logger, hub, and ZimaOS.

## Validation

When tools are available:

```bash
shellcheck scripts/*.sh
ansible-playbook --syntax-check ansible/install-nginx-proxy-manager.yml
ansible-playbook --syntax-check ansible/install-ollama-ai.yml
```

If those tools are not installed, manually inspect the changed script/playbook and update the relevant docs.
