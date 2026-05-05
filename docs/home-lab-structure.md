# Desktop-server-codex-05-05 Architecture

## Overview

| Tier | Description |
|------|-------------|
| Type | Temporary server on a desktop, built by Codex |
| Host OS | Proxmox VE on bare metal |
| Proxmox IP | 192.168.0.10 |
| RAM | 16GB |
| Main Services | ZimaOS, Home Assistant, Pi-hole, local HTTPS proxy, codex-agent AI VM, future hub/trip migration |
| HTTPS | Nginx Proxy Manager LXC at 192.168.0.31 |
| Storage | Internal disk for systems, external enclosure for data only |
| Windows | Removed from the new server; keep separate workstation if needed |

---

## Current Deployed State - 2026-05-05

| ID | Name | Type | IP | Status | Notes |
|----|------|------|----|--------|-------|
| Host | home-lab | Proxmox | 192.168.0.10 | Running | SSH key auth and web UI work. |
| 102 | zimaos | VM | 192.168.0.22 | Running | Installed from ZimaOS installer image; initial user setup complete. |
| 104 | codex-agent | VM | 192.168.0.23 | Running | AI VM project; browser access `http://ai.home/vnc.html?autoconnect=true&resize=remote`; Ubuntu 24.04.4 LTS, root SSH user, sudo installed. |
| 120 | ha | LXC | 192.168.0.20 | Running | Home Assistant Core at `http://192.168.0.20:8123`. |
| 130 | pihole | LXC | 192.168.0.30 | Running | Pi-hole DNS and web UI at `http://192.168.0.30/admin/`; router/DHCP DNS not cut over. |
| 131 | proxy | LXC | 192.168.0.31 | Running | Nginx Proxy Manager at `http://192.168.0.31:81`. |

Remaining work:

- Change the Nginx Proxy Manager default login if it has not already been changed.
- Keep router/firewall DNS unchanged until Pi-hole cutover is intentionally done.
- Complete `.home` local DNS records for Windows/local testing.
- Configure Cloudflare DNS challenge and NPM proxy hosts for the future trusted HTTPS plan.
- Attach or troubleshoot the external USB storage enclosure for ZimaOS data.
- Configure ZimaOS apps: Vaultwarden, Cloudflare Tunnel, and Immich.
- Configure backups and test restores.
- Revisit AI VM and GPU passthrough only if local model work becomes a requirement.

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
    │   ├─ [102] zimaos     → 192.168.0.22
    │   └─ [104] codex-agent → 192.168.0.23
    │
    └─ LXC Containers
        ├─ [120] ha       → 192.168.0.20 (Home Assistant)
        ├─ [130] pihole    → 192.168.0.30 (DNS + DHCP)
        └─ [131] proxy    → 192.168.0.31 (Nginx Proxy Manager)
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

---

## Target Services

| ID | Name | Type | IP | Purpose |
|----|------|------|-----|---------|
| 102 | zimaos | VM | 192.168.0.22 | NAS + app platform |
| 104 | codex-agent | VM | 192.168.0.23 | AI/Codex agent project |
| 120 | ha | LXC | 192.168.0.20 | Home Assistant |
| 130 | pihole | LXC | 192.168.0.30 | DNS + DHCP |
| 131 | proxy | LXC | 192.168.0.31 | Nginx Proxy Manager |
| 192.168.0.100-199 | Apps, services, temporary migrations |
| 192.168.0.200-249 | Workstations and user devices |

Use DHCP reservations for services where possible. Keep the Proxmox host static.

---

## Target Services

| ID | Name | Type | IP | CPU | RAM | Disk | Notes |
|----|------|------|----|-----|-----|------|-------|
| Host | proxmox | Bare metal | 192.168.0.10 | host | host | internal disk | Hypervisor |
| 102 | zimaos | VM | 192.168.0.22 | 4 vCPU | 6GB | 64GB system disk | NAS/app platform; enclosure pending |
| 104 | codex-agent | VM | 192.168.0.23 | 4 vCPU | 6GB | 40GB | AI/Codex agent project VM |
| 120 | ha | LXC | 192.168.0.20 | 2 vCPU | 1GB+ | 8GB | Home Assistant Core |
| 130 | pihole | LXC | 192.168.0.30 | 1 vCPU | 512MB | 2GB | DNS + web UI |
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

## AI VM / Codex Agent

VM `104 codex-agent` is now the AI VM project at `192.168.0.23`. It is a local
AI workstation for Codex/OpenAI agent experiments. GPU passthrough and Ollama
validation are still follow-up work unless separately confirmed.

| Item | Value |
|------|-------|
| VM ID | 104 |
| Name | codex-agent |
| IP | 192.168.0.23 |
| OS | Ubuntu 24.04.4 LTS |
| SSH user | root |
| Sudo | yes |
| Browser access | `http://ai.home/vnc.html?autoconnect=true&resize=remote` |
| CPU | 4 vCPU |
| RAM | 6GB initial |
| Disk | 40GB |
| GPU | Not confirmed |
| First Ollama test model | `qwen2.5:0.5b-base` |

Rules:

- If GPU passthrough is revisited, the GPU is exclusive to VM `104 codex-agent`.
- Do not attach the GPU to HAOS, ZimaOS, hub, trip-logger, or the Proxmox console.
- Continue non-AI migration unless AI testing becomes the active task.
- Use the small model test first because it is only about 398MB and proves the Ollama path works before larger models are attempted.

Automation:

| File | Purpose |
|------|---------|
| `docs/ai-vm-ollama.md` | AI VM, GPU passthrough, and Ollama runbook |
| `ansible/install-ollama-ai.yml` | Installs Ollama and tests `qwen2.5:0.5b-base` |

---

## Local HTTPS

Use Nginx Proxy Manager in LXC `proxy` at `192.168.0.31`.

Current local DNS status:

| Name | Points To | Status |
|------|-----------|--------|
| `ai.home` | 192.168.0.31 | Confirmed via direct Pi-hole query |
| `pihole.home` | 192.168.0.30 | Confirmed via direct Pi-hole query |
| Router/DHCP DNS | 192.168.0.30 | Not changed yet |

Use `.home` for current local/Windows testing. Keep the Cloudflare-backed
`lab.yourdomain.com` style names below as the future trusted HTTPS plan.

| Name | Points To | NPM Forwards To |
|------|-----------|-----------------|
| `proxmox.lab.yourdomain.com` | 192.168.0.31 | `https://192.168.0.10:8006` |
| `ha.lab.yourdomain.com` | 192.168.0.31 | `http://192.168.0.20:8123` |
| `zima.lab.yourdomain.com` | 192.168.0.31 | `http://192.168.0.22` |
| `pihole.lab.yourdomain.com` | 192.168.0.31 | `http://192.168.0.30/admin/` |
| `hub.lab.yourdomain.com` | 192.168.0.31 | TBD after hub migration |
| `trip.lab.yourdomain.com` | 192.168.0.31 | TBD after trip-logger migration |

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
7. Create ZimaOS VM `102` and complete web setup.
8. Create Home Assistant LXC `120` and confirm `http://192.168.0.20:8123`.
9. Create Pi-hole LXC `130` and confirm DNS resolution through `192.168.0.30`.
10. Create `proxy` LXC `131` and install Nginx Proxy Manager.
11. Configure local DNS to point HTTPS names to `192.168.0.31`.
12. Configure Nginx Proxy Manager proxy hosts and Cloudflare DNS-challenge certificate.
13. Attach the external enclosure to ZimaOS for data only.
14. Configure ZimaOS apps and backups.
15. Restore or migrate hub and trip-logger after core services are stable.
16. Validate VM `104 codex-agent` AI tooling; revisit GPU passthrough after BIOS/IOMMU settings are fixed if needed.
17. Reboot Proxmox and confirm critical services auto-start.

---

## Verification Checklist

- [x] Proxmox web UI works at `https://192.168.0.10:8006`
- [ ] hub works at `192.168.0.20`
- [x] Home Assistant works at `192.168.0.20:8123`
- [x] ZimaOS works at `192.168.0.22`
- [x] AI VM `104 codex-agent` works at `192.168.0.23`
- [ ] GPU is passed only to VM `104 codex-agent` if passthrough is enabled
- [ ] Ollama runs `qwen2.5:0.5b-base`
- [ ] trip-logger works at `192.168.0.30`
- [x] Pi-hole works at `192.168.0.30`
- [x] Nginx Proxy Manager works at `http://192.168.0.31:81`
- [ ] `https://ha.lab.yourdomain.com` works locally
- [ ] `https://zima.lab.yourdomain.com` works locally
- [ ] `https://hub.lab.yourdomain.com` works locally
- [ ] `https://trip.lab.yourdomain.com` works locally
- [ ] `https://proxmox.lab.yourdomain.com` works locally
- [ ] Router ports `80` and `443` remain closed
- [ ] Router/DHCP DNS points clients to Pi-hole `192.168.0.30`
- [ ] External enclosure is used for data only
- [ ] Backups exist outside the Proxmox system disk
