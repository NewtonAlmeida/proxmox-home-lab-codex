# AGENTS.md

## Repository Purpose

This repository documents and automates `Desktop-server-codex-05-05`, a
temporary server on a desktop built by Codex around a single bare-metal
Proxmox host.

Primary target:

- Desktop Proxmox host: `home-lab` at `192.168.0.10`
- VM range: `192.168.0.20-29`
- LXC range: `192.168.0.30-39`
- HTTPS proxy: Nginx Proxy Manager LXC at `192.168.0.31`
- AI VM/project: `104 codex-agent` at `192.168.0.23`

## Read First

- Start with `codex.md` for the repo map and task entrypoints.
- Use `docs/codex-cli-todo.md` before running Codex CLI against Proxmox.
- Use `docs/home-lab-structure.md` as the source of truth for the target architecture.
- Use `docs/control-panel.md` for the user-editable human progress tracker.
- Complete Section 0 (SSH Setup) in todo doc before running Codex.

---

## Codex Exec Mode

Run Codex non-interactively:

```bash
codex exec --full-auto "Deploy Pi-hole by following docs/codex-cli-todo.md"
```

The `--full-auto` flag allows Codex to:
- Run commands without prompts
- Use SSH with key file (not agent)
- Complete multi-step tasks

SSH config in `~/.ssh/config` prevents password prompts:

```
Host home-lab
  HostName 192.168.0.10
  User root
  IdentityFile ~/.ssh/home-lab-codex
  BatchMode yes
  StrictHostKeyChecking accept-new
```

## Working Rules

- Do not expose Proxmox directly to the internet.
- Do not open router ports `80` or `443` unless the user explicitly changes the local-only HTTPS plan.
- Do not store Cloudflare tokens, passwords, SSH keys, or Bitwarden secrets in this repository.
- Keep VM system disks on internal Proxmox storage.
- Keep the external enclosure for data only.
- If GPU passthrough is revisited, pass the GPU only to VM `104 codex-agent`.
- Test Ollama with `qwen2.5:0.5b-base` before relying on the AI VM for larger local models.

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

---

## Code Style Guidelines

### Shell Scripts (`scripts/*.sh`)

Follow these conventions for all bash/shell scripts:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

| Convention | Rule |
|------------|------|
| Shebang | Use `#!/usr/bin/env bash` |
| Error handling | Always use `set -euo pipefail` |
| Variables | Use `${VAR:-default}` for defaults; quote all expansions |
| Conditionals | Use `[[ ]]` (bash) over `[ ]` (POSIX) |
| Functions | Named with `snake_case`, defined before use |
| Exit codes | 0=success, 1=failure, 2=usage error |
| Output | Use stderr for errors (`>&2`), stdout for normal output |

**Example template:**

```bash
#!/usr/bin/env bash
set -euo pipefail

VAR="${VAR:-default_value}"

if [[ "${#}" -ne 1 ]]; then
  echo "Usage: $0 <arg>" >&2
  exit 1
fi

main() {
  echo "Doing work with: $1"
}

main "$@"
```

**Lint command:** `shellcheck scripts/*.sh`

---

### Ansible Playbooks (`ansible/*.yml`)

| Convention | Rule |
|------------|------|
| Indentation | 2 spaces (YAML standard) |
| Keys | `ansible.builtin.<module>` for built-in modules |
| Privileges | Use `become: true` only when necessary |
| Facts | Always `gather_facts: true` unless disabled |
| Idempotency | Use `changed_when: false` for info-only commands |
| Variables | Use `{{ var }}` with quotes; no spaces inside |
| Tasks | One action per task; use `name:` for all tasks |

**Example:**

```yaml
---
- name: Task description
  hosts: all
  become: true
  gather_facts: true

  tasks:
    - name: Install package
      ansible.builtin.apt:
        name: "{{ packages }}"
        state: present
        update_cache: true

    - name: Check service status
      ansible.builtin.command:
        cmd: systemctl is-active nginx
      register: nginx_status
      changed_when: false
```

**Lint command:** `ansible-playbook --syntax-check ansible/<playbook>.yml`

---

### Docker Compose (`proxy/docker-compose.yml`)

| Convention | Rule |
|------------|------|
| Indentation | 2 spaces |
| Images | Use `:latest` or pinned `:tag` (never `:latest` in production) |
| Restart policy | Always specify `restart: unless-stopped` |
| Environment | Use uppercase with underscores `KEY=value` |
| Volumes | Use relative paths `./data` |
| Networks | Omit if single-network; use explicit for multi-service |
| Ports | Quote numeric ports only if string needed |

**Example:**

```yaml
services:
  app:
    image: nginx:latest
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    environment:
      TZ: "UTC"
    volumes:
      - ./data:/data
```

---

### Markdown Docs (`docs/*.md`)

| Convention | Rule |
|------------|------|
| Headings | Use ATX style (`#`, `##`, `###`); no closing `##` |
| Code blocks | Specify language: ` ```bash ``` ` |
| Lists | Use `-` for unordered; `1.` for ordered |
| Links | Use relative paths for internal refs |
| Tables | Align pipes; use `|---|` for separators |
| Line length | Soft wrap at ~100 chars when practical |

**Frontmatter (if any):** Use YAML block style only.

---

## Command Reference

### Run All Linters (when available)

```bash
shellcheck scripts/*.sh
ansible-playbook --syntax-check ansible/*.yml
```

### Run Single File Lint

```bash
# Shell script
shellcheck scripts/create-proxy-lxc.sh

# Ansible playbook
ansible-playbook --syntax-check ansible/install-ollama-ai.yml
```

### Dry-Run Ansible

```bash
ansible-playbook -i ansible/inventory.ini ansible/<playbook>.yml --check
```

### Update Ansible Inventory

```bash
ansible-inventory -i ansible/inventory.ini --list
```

---

## Naming Conventions

| Object | Convention | Example |
|--------|------------|---------|
| Shell scripts | `snake_case.sh` | `create-proxy-lxc.sh` |
| Ansible playbooks | `snake_case.yml` | `install-nginx-proxy-manager.yml` |
| Ansible roles | `snake_case` | (not currently used) |
| LXC containers | `snake_case` | `proxy`, `ai` |
| VMs | `snake_case` | `haos`, `zimaos` |
| Variables | `snake_case` | `npm_install_dir` |
| Task names | Sentence case | "Install Docker packages" |

---

## Directory Structure

```
.
├── AGENTS.md              # This file - agent instructions
├── codex.md              # Repo map and task entrypoints
├── README.md             # Human overview
├── docs/                 # Human documentation, runbooks
│   ├── codex-cli-todo.md
│   ├── home-lab-structure.md
│   └── *.md
├── scripts/             # Proxmox-side scripts (run via SSH)
│   └── *.sh
├── ansible/             # Ansible playbooks for guest config
│   ├── *.yml
│   ├── inventory.ini
│   └── group_vars/
├── proxy/               # Nginx Proxy Manager compose files
│   └── docker-compose.yml
└── rules/               # Safety and workflow rules
    ├── lab-safety.md
    └── codex-workflow.md
```

---

## Common Operations

### Test SSH Connectivity

```bash
ssh -o BatchMode=yes -o ConnectTimeout=5 root@192.168.0.10 "pvesm status"
```

### List VMs and LXCs

```bash
ssh root@192.168.0.10 "qm list && pct list"
```

### Run Single Script via SSH

```bash
ssh root@192.168.0.10 "bash -s" < scripts/create-proxy-lxc.sh
```

### Execute Single Ansible Tag

```bash
ansible-playbook -i ansible/inventory.ini ansible/<playbook>.yml --tags <tag>
```

---

## Error Handling

| Situation | Action |
|-----------|--------|
| Shell script fails | Check `set -euo pipefail` caught it; read stderr |
| Ansible task fails | Re-run with `-vvv` for verbose output |
| Proxmox command fails | Verify VM/CT exists; check network/firewall |
| Git conflict | Prefer docs update; ask user to resolve automation files |
