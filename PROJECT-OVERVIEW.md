# Desktop-server-codex-05-05

Project: a temporary server on a desktop, built by Codex.

This repository tracks the current desktop-based server build, the services that
are already running, and the work still planned to finish the setup cleanly.

## Topology

```text
desktop
└─ proxmox
   ├─ vms
   │  ├─ zimaos
   │  └─ codex-vm
   └─ lxcs
      ├─ home assistant
      ├─ pihole
      └─ nginx proxy manager
```

## IP Plan

| Item | IP | Notes |
|------|----|-------|
| Proxmox host | `192.168.0.10` | Bare-metal host |
| Home Assistant | `192.168.0.20` | LXC |
| ZimaOS | `192.168.0.22` | VM |
| Codex VM | `192.168.0.23` | VM |
| Pi-hole | `192.168.0.30` | LXC |
| Nginx Proxy Manager | `192.168.0.31` | LXC |

## What Is Done

- Proxmox is installed and reachable on the desktop host.
- SSH key-based admin access is working.
- Home Assistant is running in an LXC container.
- Pi-hole is running and answering DNS queries.
- Nginx Proxy Manager is running.
- ZimaOS is installed and booting normally.
- The Codex VM exists and is accessible through the browser console.
- The repo documentation has been updated to track the live state of the build.

## What Is Planned

- Finish the local DNS and HTTPS story.
- Confirm or change the Nginx Proxy Manager admin login.
- Decide whether router DNS should stay local-only or be cut over later.
- Attach and validate the external storage path for ZimaOS data.
- Configure ZimaOS apps and backup jobs.
- Revisit GPU passthrough and Ollama validation for the Codex VM if needed.
- Add or refine service proxy hosts as the project expands.

## Current Status

| Area | Status |
|------|--------|
| Proxmox | Running |
| Home Assistant | Running |
| Pi-hole | Running |
| Nginx Proxy Manager | Running |
| ZimaOS | Running |
| Codex VM | Running |
| Local DNS | Partial |
| HTTPS | Planned |
| External storage | Planned |

## Where To Read Next

- [README.md](./README.md)
- [docs/control-panel.md](./docs/control-panel.md)
- [docs/home-lab-structure.md](./docs/home-lab-structure.md)
- [docs/codex-cli-todo.md](./docs/codex-cli-todo.md)
