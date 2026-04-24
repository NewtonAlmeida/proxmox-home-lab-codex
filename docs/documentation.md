# Home Lab Documentation

This file is the editable human version of the home lab plan.

## Quick Summary

The new home lab target is a single bare-metal Proxmox server.

| Item | Value |
|------|-------|
| Proxmox hostname | `home-lab` |
| Proxmox IP | `192.168.0.10` |
| Gateway | `192.168.0.1` |
| DNS | `192.168.0.1` |
| RAM | 16GB |
| HTTPS proxy | Nginx Proxy Manager |
| Proxy IP | `192.168.0.31` |
| Credentials | Bitwarden: `home-lab` |
| AI VM | `ai` at `192.168.0.23` |

## IP Plan

| Range | Use |
|-------|-----|
| `192.168.0.10-19` | Proxmox and management |
| `192.168.0.20-29` | VMs |
| `192.168.0.30-39` | LXC containers |
| `192.168.0.40-99` | Network devices |
| `192.168.0.100-199` | Apps / temporary services |
| `192.168.0.200-249` | Workstations and user devices |

## Target Services

| Service | Type | IP | Notes |
|---------|------|----|-------|
| Proxmox | Host | `192.168.0.10` | Main hypervisor |
| hub | VM | `192.168.0.20` | Gemini management hub |
| Home Assistant OS | VM | `192.168.0.21` | Smart home |
| ZimaOS | VM | `192.168.0.22` | NAS / apps |
| ai | VM | `192.168.0.23` | Ollama with exclusive GPU passthrough |
| trip-logger | LXC | `192.168.0.30` | Small app |
| proxy | LXC | `192.168.0.31` | Nginx Proxy Manager |

## Storage Notes

- Internal disk is for Proxmox, VMs, LXCs, and system disks.
- External enclosure is for data only.
- Do not place VM boot disks on the external enclosure.
- Keep backups outside the Proxmox system disk.

## AI VM Plan

Create a new VM:

| Item | Value |
|------|-------|
| VM ID | `104` |
| Name | `ai` |
| IP | `192.168.0.23` |
| Service | Ollama |
| GPU | Passed through only to this VM |
| First test model | `qwen2.5:0.5b-base` |

Important:

- The GPU must be attached only to the `ai` VM.
- Do not attach the GPU to ZimaOS, HAOS, hub, or any container.
- Test a small Ollama model before changing anything else.
- If the small model fails, stop and fix the AI VM before continuing migration.

## HTTPS Plan

Use Nginx Proxy Manager at:

```text
http://192.168.0.31:81
```

Local HTTPS names:

| Name | Target |
|------|--------|
| `proxmox.lab.yourdomain.com` | Proxmox |
| `haos.lab.yourdomain.com` | Home Assistant |
| `zima.lab.yourdomain.com` | ZimaOS |
| `hub.lab.yourdomain.com` | hub |
| `trip.lab.yourdomain.com` | trip-logger |

Cloudflare is used only for DNS challenge certificates.

Do not open router ports `80` or `443` for now.

## Migration Checklist

- [ ] Confirm Proxmox web UI works at `https://192.168.0.10:8006`
- [ ] Confirm SSH to Proxmox works
- [ ] Create proxy LXC
- [ ] Install Nginx Proxy Manager
- [ ] Configure Cloudflare DNS challenge
- [ ] Add local DNS records
- [ ] Back up old Home Assistant
- [ ] Back up old ZimaOS
- [ ] Back up old hub
- [ ] Back up old trip-logger
- [ ] Create AI VM at `192.168.0.23`
- [ ] Pass GPU only to AI VM
- [ ] Install Ollama
- [ ] Test `qwen2.5:0.5b-base`
- [ ] Restore Home Assistant
- [ ] Restore trip-logger
- [ ] Restore hub
- [ ] Restore or rebuild ZimaOS
- [ ] Confirm HTTPS names work locally
- [ ] Confirm backups are working

## Notes

Use this space for edits, reminders, passwords location notes, hardware notes, or anything useful.

- Proxmox credentials are stored in Bitwarden (BW) under the entry `home-lab`.
