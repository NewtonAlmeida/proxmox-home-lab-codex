# HOME LAB STRUCTURE - SINGLE PROXMOX TARGET 2026

## Overview

| Tier | Description |
|------|-------------|
| Type | Permanent single-node Proxmox home lab |
| Host OS | Proxmox VE on bare metal |
| Proxmox IP | 192.168.0.10 |
| RAM | 16GB |
| Main Services | hub, Home Assistant OS, ZimaOS, ai/Ollama, trip-logger, local HTTPS proxy |
| HTTPS | Nginx Proxy Manager LXC at 192.168.0.31 |
| Storage | Internal disk for systems, external enclosure for data only |
| Windows | Removed from the new server; keep separate workstation if needed |

---

## Target Network Topology

```
INTERNET
    │
[Firewall / Router]
    │
[Switch]
    │
Proxmox Host - 192.168.0.10
    │
    ├─ VMs
    │   ├─ [100] hub    → 192.168.0.20
    │   ├─ [101] haos   → 192.168.0.21
    │   ├─ [102] zimaos → 192.168.0.22
    │   └─ [104] ai     → 192.168.0.23
    │
    └─ LXC Containers
        ├─ [103] trip-logger → 192.168.0.30
        └─ [131] proxy       → 192.168.0.31
```

---

## IP Management

| Range | Purpose |
|-------|---------|
| 192.168.0.1 | Gateway / router |
| 192.168.0.10-19 | Proxmox hosts and management |
| 192.168.0.20-29 | VMs |
| 192.168.0.30-39 | LXC containers |
| 192.168.0.40-99 | Network devices, switches, access points |
| 192.168.0.100-199 | Apps, services, temporary migrations |
| 192.168.0.200-249 | Workstations and user devices |

Use DHCP reservations for services where possible. Keep the Proxmox host static.

---

## Target Services

| ID | Name | Type | IP | CPU | RAM | Disk | Notes |
|----|------|------|----|-----|-----|------|-------|
| Host | proxmox | Bare metal | 192.168.0.10 | host | host | internal disk | Hypervisor |
| 100 | hub | VM | 192.168.0.20 | 2 vCPU | 2GB | 32GB | Gemini management hub |
| 101 | haos | VM | 192.168.0.21 | 2 vCPU | 4GB | 64GB | Home Assistant OS |
| 102 | zimaos | VM | 192.168.0.22 | 4 vCPU | 6GB | 64GB system disk | NAS/app platform; enclosure for data |
| 104 | ai | VM | 192.168.0.23 | 4 vCPU | 6GB | 64GB+ | Ollama test VM; only VM with GPU passthrough |
| 103 | trip-logger | LXC | 192.168.0.30 | 1 vCPU | 1GB | 8-16GB | Small service |
| 131 | proxy | LXC | 192.168.0.31 | 1 vCPU | 1GB | 8GB | Nginx Proxy Manager |

### VM / CT Decisions

| Service | Best Form | Reason |
|---------|-----------|--------|
| Home Assistant OS | VM | Full HAOS appliance with Supervisor, add-ons, backups, and clean USB passthrough |
| ZimaOS | VM | Designed as its own OS; cleaner storage and app isolation |
| ai/Ollama | VM | GPU passthrough requires a VM; the GPU must be assigned only to this VM |
| hub | VM | Easiest migration from existing lab1 VM |
| trip-logger | LXC | Small service; keep it lightweight and practical |
| Nginx Proxy Manager | LXC + Docker | Beginner-friendly HTTPS UI; easy to rerun with Ansible |

---

## Storage Layout

| Storage | Use |
|---------|-----|
| Internal SSD/NVMe | Proxmox OS, VM disks, LXC disks, databases, HAOS, ZimaOS system disk |
| External enclosure | Data only: media, photos, documents, ZimaOS shares, backups |
| Separate backup target | Critical backups for HAOS, ZimaOS app data, hub, and trip-logger |

Rules:

- Do not place Proxmox, VM system disks, or databases on the external enclosure.
- Keep the enclosure for data only.
- Keep at least one backup outside the Proxmox system disk.
- Keep Ollama models on internal storage unless a separate fast model disk is added later.

---

## AI VM And GPU Passthrough

Create VM `104 ai` at `192.168.0.23` before changing the rest of the lab.

| Item | Value |
|------|-------|
| VM ID | 104 |
| Name | ai |
| IP | 192.168.0.23 |
| OS | Ubuntu Server LTS or Debian |
| CPU | 4 vCPU |
| RAM | 6GB initial |
| Disk | 64GB minimum |
| GPU | Pass through the whole GPU only to this VM |
| First test model | `qwen2.5:0.5b-base` |

Rules:

- The GPU is exclusive to VM `104 ai`.
- Do not attach the GPU to HAOS, ZimaOS, hub, trip-logger, or the Proxmox console.
- Do not continue the rest of the migration until Ollama runs a small model successfully.
- Use the small model test first because it is only about 398MB and proves the Ollama path works before larger models are attempted.

Automation:

| File | Purpose |
|------|---------|
| `docs/ai-vm-ollama.md` | AI VM, GPU passthrough, and Ollama runbook |
| `ansible/install-ollama-ai.yml` | Installs Ollama and tests `qwen2.5:0.5b-base` |

---

## Local HTTPS

Use Nginx Proxy Manager in LXC `proxy` at `192.168.0.31`.

| Name | Points To | NPM Forwards To |
|------|-----------|-----------------|
| `proxmox.lab.yourdomain.com` | 192.168.0.31 | `https://192.168.0.10:8006` |
| `haos.lab.yourdomain.com` | 192.168.0.31 | `http://192.168.0.21:8123` |
| `zima.lab.yourdomain.com` | 192.168.0.31 | `http://192.168.0.22` |
| `hub.lab.yourdomain.com` | 192.168.0.31 | `http://192.168.0.20` |
| `trip.lab.yourdomain.com` | 192.168.0.31 | `http://192.168.0.30` |

Rules:

- Use Cloudflare DNS challenge for certificates.
- Keep access local-only for now.
- Do not open router ports `80` or `443`.
- Do not expose Proxmox directly to the internet.
- Add Cloudflare Tunnel later only for selected services if needed.

Docs and automation:

| File | Purpose |
|------|---------|
| `docs/https-local-npm.md` | Beginner runbook |
| `docs/codex-cli-ssh-execution.md` | Codex CLI SSH execution guide |
| `scripts/create-proxy-lxc.sh` | Creates LXC `131 proxy` on Proxmox |
| `ansible/install-nginx-proxy-manager.yml` | Installs Docker + Nginx Proxy Manager |
| `ansible/inventory.example.ini` | Example Ansible inventory |

---

## Current Source Lab

These are the existing services to migrate into the single-node target.

### lab1 - Current Primary

| Item | Value |
|------|-------|
| IP | 192.168.0.10 |
| Role | Existing hypervisor + management hub |
| OS | Proxmox VE 9.1.1 |
| RAM | 16GB |

| ID | Name | Type | IP | CPU | RAM | Purpose |
|----|------|------|----|-----|-----|---------|
| 100 | hub | VM | 192.168.0.167 | 2 vCPU | 2GB | Gemini management hub |
| 103 | trip-logger | LXC | 192.168.0.150 | 1 vCPU | 1GB | Kanga trip logger |

### lab2 - Current Storage & Smart Home

| Item | Value |
|------|-------|
| IP | 192.168.0.11 |
| Role | Existing NAS + automation |
| OS | Proxmox VE 9.1.4 |
| RAM | 16GB |
| Storage Risk | ZFS `data` pool is ~97% full - critical |

| ID | Name | Type | IP | CPU | RAM | Purpose |
|----|------|------|----|-----|-----|---------|
| 100 | haos | VM | 192.168.0.176 | 2 vCPU | 4GB | Home Assistant OS |
| 101 | ZimaOS | VM | 192.168.0.163 | 4 vCPU | 8GB | NAS and app platform |

### lab2 Storage

| Storage | Type | Size / Status | Purpose |
|---------|------|---------------|---------|
| local-lvm | LVM-thin | ~349GB | VM disks |
| data | ZFS pool | ~7.3TB, 97% full | NAS data, ZimaOS storage |

---

## Migration Order

1. Back up Home Assistant OS from current lab2 VM 100.
2. Back up ZimaOS app data and configuration from current lab2 VM 101.
3. Back up hub from current lab1 VM 100.
4. Back up trip-logger data/config from current lab1 CT 103.
5. Install Proxmox bare metal on the new single host.
6. Create target VMs and containers using the `.20` VM range and `.30` container range.
7. Create VM `104 ai` at `192.168.0.23`.
8. Pass the GPU only to VM `104 ai`.
9. Install Ollama in `ai`.
10. Test `qwen2.5:0.5b-base` before changing anything else.
11. Create `proxy` LXC 131 at `192.168.0.31`.
12. Run Ansible to install Docker + Nginx Proxy Manager in `proxy`.
13. Restore HAOS first and test `http://192.168.0.21:8123`.
14. Restore trip-logger and test `192.168.0.30`.
15. Restore hub and test `192.168.0.20`.
16. Restore/create ZimaOS and attach the external enclosure for data only.
17. Configure local DNS to point HTTPS names to `192.168.0.31`.
18. Configure Nginx Proxy Manager proxy hosts and Cloudflare DNS-challenge certificate.
19. Reboot Proxmox and confirm critical services auto-start.

---

## Verification Checklist

- [ ] Proxmox web UI works at `https://192.168.0.10:8006`
- [ ] hub works at `192.168.0.20`
- [ ] HAOS works at `192.168.0.21:8123`
- [ ] ZimaOS works at `192.168.0.22`
- [ ] ai VM works at `192.168.0.23`
- [ ] GPU is passed only to VM `104 ai`
- [ ] Ollama runs `qwen2.5:0.5b-base`
- [ ] trip-logger works at `192.168.0.30`
- [ ] Nginx Proxy Manager works at `http://192.168.0.31:81`
- [ ] `https://haos.lab.yourdomain.com` works locally
- [ ] `https://zima.lab.yourdomain.com` works locally
- [ ] `https://hub.lab.yourdomain.com` works locally
- [ ] `https://trip.lab.yourdomain.com` works locally
- [ ] `https://proxmox.lab.yourdomain.com` works locally
- [ ] Router ports `80` and `443` remain closed
- [ ] External enclosure is used for data only
- [ ] Backups exist outside the Proxmox system disk
