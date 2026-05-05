# Scripts

Scripts in this directory are intended to be copied to or run against the Proxmox host.

Current scripts:

| Script | Purpose |
|--------|---------|
| `setup-codex-env.sh` | Setup Codex environment (SSH key, config, inventory) - run from repo root |
| `create-proxy-lxc.sh` | Create Debian LXC `131 proxy` at `192.168.0.31` |
| `create-pihole-lxc.sh` | Create Debian LXC `130 pihole` at `192.168.0.30` |
| `create-home-assistant-lxc.sh` | Create Debian LXC `120 ha` at `192.168.0.20` |

Rules:

- Run `setup-codex-env.sh` first before using Codex
- Read the script before running it.
- Do not run destructive storage commands from this directory.
- Prefer explicit environment variables over editing scripts for one-off values.

