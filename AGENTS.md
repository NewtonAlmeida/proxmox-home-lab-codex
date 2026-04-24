# AGENTS.md

## Repository Purpose

This repository documents and automates a home lab migration to a single bare-metal Proxmox host.

Primary target:

- Proxmox host: `home-lab` at `192.168.0.10`
- VM range: `192.168.0.20-29`
- LXC range: `192.168.0.30-39`
- HTTPS proxy: Nginx Proxy Manager LXC at `192.168.0.31`
- AI VM: `ai` at `192.168.0.23` with exclusive GPU passthrough

## Read First

- Start with `codex.md` for the repo map and task entrypoints.
- Use `docs/codex-cli-todo.md` before running Codex CLI against Proxmox.
- Use `docs/home-lab-structure.md` as the source of truth for the target architecture.
- Use `docs/documentation.md` for the user-editable human version.

## Working Rules

- Do not expose Proxmox directly to the internet.
- Do not open router ports `80` or `443` unless the user explicitly changes the local-only HTTPS plan.
- Do not store Cloudflare tokens, passwords, SSH keys, or Bitwarden secrets in this repository.
- Keep VM system disks on internal Proxmox storage.
- Keep the external enclosure for data only.
- Pass the GPU only to VM `104 ai`.
- Test Ollama with `qwen2.5:0.5b-base` before continuing other migration work.

## Execution Rules

- Prefer updating docs and scripts over giving one-off terminal instructions.
- Use SSH to run Proxmox-native commands on `home-lab` / `192.168.0.10`.
- Prefer SSH key auth with `BatchMode=yes`; do not rely on interactive password prompts.
- Use Ansible for repeatable guest configuration when available.
- Do not build or assume a Proxmox MCP layer unless the user explicitly asks for it later.
- Before changing automation, inspect existing docs, scripts, and Ansible files.
- After changing automation, update `docs/codex-cli-todo.md` if the operator steps change.

## Validation

When relevant, verify with:

- `shellcheck scripts/*.sh` when shellcheck is available.
- `ansible-playbook --syntax-check <playbook>` when Ansible is available.
- Manual read-through of changed Markdown if local tooling is unavailable.
