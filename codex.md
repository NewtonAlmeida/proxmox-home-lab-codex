# codex.md

This is the repo index for Codex and for the human operator. The official Codex instruction entrypoint is `AGENTS.md`; this file is the durable project map.

## Current Goal

Build a single-node bare-metal Proxmox home lab with:

- `home-lab` Proxmox host at `192.168.0.10`
- VMs in `192.168.0.20-29`
- LXC containers in `192.168.0.30-39`
- Local-only HTTPS through Nginx Proxy Manager
- AI VM `ai` at `192.168.0.23` with exclusive GPU passthrough and Ollama

## Repo Structure

| Path | Purpose |
|------|---------|
| `AGENTS.md` | Official Codex project instructions |
| `codex.md` | Repo map and operator entrypoint |
| `docs/` | Human docs, runbooks, migration checklists |
| `scripts/` | Proxmox-side helper scripts |
| `ansible/` | Repeatable guest configuration playbooks |
| `proxy/` | Nginx Proxy Manager Docker Compose files |
| `rules/` | Repo-specific operational and safety rules |

## Primary Docs

| File | Purpose |
|------|---------|
| `docs/documentation.md` | User-editable human documentation |
| `docs/home-lab-structure.md` | Target architecture and migration order |
| `docs/codex-cli-todo.md` | Codex CLI execution checklist |
| `docs/codex-cli-ssh-execution.md` | SSH/Ansible execution guide |
| `docs/https-local-npm.md` | Nginx Proxy Manager HTTPS runbook |
| `docs/ai-vm-ollama.md` | AI VM, GPU passthrough, and Ollama runbook |

## Automation Entry Points

| File | Use |
|------|-----|
| `scripts/create-proxy-lxc.sh` | Create LXC `131 proxy` at `192.168.0.31` |
| `ansible/install-nginx-proxy-manager.yml` | Install Docker + Nginx Proxy Manager |
| `ansible/install-ollama-ai.yml` | Install Ollama and test a small model |

## Next Operator Path

1. Read `docs/codex-cli-todo.md`.
2. Confirm SSH to `root@192.168.0.10`.
3. Create and test VM `104 ai` at `192.168.0.23`.
4. Pass the GPU only to the AI VM.
5. Install Ollama and test `qwen2.5:0.5b-base`.
6. Create `proxy` LXC and install Nginx Proxy Manager.
7. Continue service migration only after AI and proxy checks pass.

## Official Codex Notes

OpenAI Codex discovers `AGENTS.md` files automatically. `codex.md` is kept as a project index, not as the primary instruction file, unless a Codex config explicitly adds it as a fallback filename.

