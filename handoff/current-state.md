# Current State

Last updated: 2026-05-05

## Target Proxmox Host

| Item | Value |
|------|-------|
| Host alias | `home-lab` |
| IP | `192.168.0.10` |
| User | `root` |
| SSH key | `~/.ssh/home-lab-codex` |
| Status | Powered off at the end of the last session |

Before shutdown, these guests existed on `home-lab`:

| ID | Name | Type | IP | Last known state before host shutdown |
|----|------|------|----|--------------------------------------|
| 102 | `zimaos` | VM | `192.168.0.22` | Gracefully stopped |
| 104 | `ai` | VM | `192.168.0.23` | Running desktop stack for computer use |
| 120 | `ha` | LXC | `192.168.0.20` | Gracefully stopped |
| 130 | `pihole` | LXC | `192.168.0.30` | Gracefully stopped |
| 131 | `proxy` | LXC | `192.168.0.31` | Gracefully stopped |

The host was then shut down with `systemctl poweroff`.

## Source Proxmox Host

| Item | Value |
|------|-------|
| Host alias | `lab2` |
| IP | `192.168.0.11` |
| User | `root` |
| SSH auth | Bitwarden SSH agent prompts |
| Proxmox version seen | `pve-manager/9.1.4` |

Source VMs to migrate:

| ID | Name | IP | Purpose |
|----|------|----|---------|
| 100 | `haos-16.3` | `192.168.0.176` | Current Home Assistant OS with settings/add-ons |
| 101 | `ZimaOS` | `192.168.0.163` | Current ZimaOS with apps and data |

## Important Source VM Disk Facts

HAOS VM `100`:

- `scsi0`: 32G OS disk.
- `scsi1`: 350G extra disk. It reported `0.00%` data usage in LVM-thin, but verify before excluding it from backups.
- Uses OVMF/UEFI.

ZimaOS VM `101`:

- `sata0`: about 82G system disk.
- `virtio1`: about 7T data disk on source ZFS pool `data`.
- USB passthrough existed on old VM: `usb0: host=2-7` and `usb1: host=1a86:7523`.
- The 7T data disk should not be migrated yet because the new host internal storage cannot hold it.

## Current Target Storage Constraint

The new `home-lab` had about 127G free on `local-lvm` at last check. That is
enough for system-disk restore tests, but not enough for the old ZimaOS 7T data
disk.

## AI VM Access Layer

| Item | Value | Notes |
|------|-------|-------|
| AI VM | `104` / `ai` | `codex-agent` desktop stack for computer use |
| AI VM IP | `192.168.0.23` | Raw VNC stays private on the VM |
| DNS name | `ai.home` | Resolves to the proxy through Pi-hole |
| Pi-hole | `130` / `pihole` | `192.168.0.30` |
| Proxy | `131` / `proxy` | `192.168.0.31` |
| Desktop URL | `http://ai.home/vnc.html?autoconnect=true&resize=remote` | LAN access through Nginx Proxy Manager |

## Work Already Done On New Host

- Installed Proxmox on `192.168.0.10`.
- Set up SSH key access as `home-lab`.
- Created fresh ZimaOS VM `102`.
- Created fresh Home Assistant Core LXC `120`.
- Created Pi-hole LXC `130`.
- Created Nginx Proxy Manager LXC `131`.
- Created AI VM `104` and wired `ai.home` through Pi-hole and the proxy.

